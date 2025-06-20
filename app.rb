require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require 'bcrypt'
require 'json'
require 'date'

# Database configuration
set :database, { adapter: 'sqlite3', database: 'household.db' }

# Enable sessions
enable :sessions

# --- Models ---
class Admin < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
end

class Member < ActiveRecord::Base
  has_many :tasks
  has_many :task_completions
  has_many :task_skips
  validates :name, presence: true, uniqueness: true
end

class Task < ActiveRecord::Base
  belongs_to :member
  has_many :task_completions
  has_many :task_skips
  validates :title, presence: true
  validates :status, inclusion: { in: %w[todo in_progress done skipped] }

  def points_value
    case difficulty
    when 'easy' then 1
    when 'medium' then 2
    when 'hard' then 3
    else 1
    end
  end
end

class TaskCompletion < ActiveRecord::Base
  belongs_to :task
  belongs_to :member
  validates :completed_at, presence: true
end

class TaskSkip < ActiveRecord::Base
  belongs_to :task
  belongs_to :member
  validates :reason, presence: true
  validates :skipped_at, presence: true
end

# --- Database Schema ---
ActiveRecord::Schema.define do
  create_table :admins, force: true do |t|
    t.string :username, null: false
    t.string :password_digest, null: false
    t.timestamps
  end

  create_table :members, force: true do |t|
    t.string :name, null: false
    t.string :avatar_url
    t.boolean :active, default: true
    t.timestamps
  end

  create_table :tasks, force: true do |t|
    t.string :title, null: false
    t.text :description
    t.string :status, default: 'todo'
    t.string :difficulty, default: 'medium'
    t.string :category
    t.integer :member_id
    t.date :due_date
    t.integer :points, default: 1
    t.timestamps
  end

  create_table :task_completions, force: true do |t|
    t.integer :task_id, null: false
    t.integer :member_id, null: false
    t.datetime :completed_at, null: false
    t.text :notes
    t.timestamps
  end

  create_table :task_skips, force: true do |t|
    t.integer :task_id, null: false
    t.integer :member_id, null: false
    t.datetime :skipped_at, null: false
    t.text :reason, null: false
    t.timestamps
  end
end

# --- Helpers ---
helpers do
  # Admin helpers
  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

  def admin_logged_in?
    !!current_admin
  end

  def require_admin_login
    redirect '/admin/login' unless admin_logged_in?
  end

  # Member helpers
  def current_member
    @current_member ||= Member.find(session[:member_id]) if session[:member_id]
  end

  def member_selected?
    !!current_member
  end

  # Flash message helpers
  def flash_message
    session.delete(:flash) if session[:flash]
  end

  def set_flash(type, message)
    session[:flash] = { type: type, message: message }
  end

  # Data helpers
  def completed_today(member)
    member.task_completions.where('completed_at >= ?', Date.today.beginning_of_day).count
  end

  def outstanding_tasks(member)
    member.tasks.where(status: ['todo', 'in_progress']).count
  end

  def calculate_member_points(member, start_date = 30.days.ago)
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    completions.sum { |tc| tc.task.points_value }
  end

  def calculate_member_skips(member, start_date = 30.days.ago)
    member.task_skips.where('skipped_at >= ?', start_date).count
  end

  def calculate_completion_rate(member, start_date)
    total_tasks = member.tasks.where('created_at >= ?', start_date).count
    completed_tasks = member.task_completions.joins(:task).where('completed_at >= ?', start_date).count
    return 0 if total_tasks == 0
    (completed_tasks.to_f / total_tasks * 100).round(1)
  end
end

# --- Routes ---

# Homepage (Profile selection)
get '/' do
  session.clear
  @members = Member.where(active: true)
  erb :index
end

namespace '/admin' do
  # Admin Authentication
  get '/login' do
    erb :login
  end

  post '/login' do
    admin = Admin.find_by(username: params[:username])
    if admin && BCrypt::Password.new(admin.password_digest) == params[:password]
      session[:admin_id] = admin.id
      set_flash('success', "Welcome back, Admin!")
      redirect '/admin/dashboard'
    else
      set_flash('error', 'Invalid admin username or password')
      redirect '/admin/login'
    end
  end

  get '/logout' do
    session.clear
    set_flash('success', 'You have been logged out')
    redirect '/'
  end

  before '/*' do
    pass if request.path_info == '/admin/login'
    require_admin_login
  end

  get '/dashboard' do
    @members = Member.where(active: true)
    @tasks_by_member = Task.includes(:member).order(:created_at).group_by(&:member)
    erb :admin_dashboard
  end

  # Task Management (for Admins)
  post '/tasks' do
    task = Task.new(
      title: params[:title],
      description: params[:description],
      difficulty: params[:difficulty],
      category: params[:category],
      member_id: params[:member_id],
      due_date: params[:due_date],
      points: params[:points] || 1
    )

    if task.save
      set_flash('success', 'Task created successfully!')
    else
      set_flash('error', 'Error creating task')
    end
    redirect back
  end

  # Member Management (for Admins)
  get '/members' do
    @members = Member.all
    erb :members
  end

  post '/members' do
    member = Member.new(name: params[:name], avatar_url: params[:avatar_url])

    if member.save
      set_flash('success', 'Member created successfully!')
    else
      set_flash('error', 'Error creating member')
    end
    redirect '/admin/members'
  end

  # Admin Management
  get '/admins' do
    @admins = Admin.all
    erb :admins
  end

  post '/admins' do
    password_digest = BCrypt::Password.create(params[:password])
    admin = Admin.new(username: params[:username], password_digest: password_digest)

    if admin.save
      set_flash('success', 'Admin created successfully!')
    else
      set_flash('error', 'Error creating admin: ' + admin.errors.full_messages.join(', '))
    end
    redirect '/admin/admins'
  end

  # Reporting (for Admins)
  get '/reports' do
    @members = Member.where(active: true)
    @period = params[:period] || '30'
    @start_date = @period.to_i.days.ago

    @member_stats = @members.map do |member|
      {
        member: member,
        points: calculate_member_points(member, @start_date),
        skips: calculate_member_skips(member, @start_date),
        completions: member.task_completions.where('completed_at >= ?', @start_date).count,
        completion_rate: calculate_completion_rate(member, @start_date)
      }
    end

    erb :reports
  end
end

# Member Login and Dashboard
get '/members/:id/select' do
  session[:member_id] = params[:id]
  redirect '/dashboard'
end

get '/dashboard' do
  # An admin can view the main dashboard, a member sees their own.
  if !member_selected?
    redirect '/'
  end

  @tasks = current_member.tasks.includes(:member).order(:created_at)
  erb :dashboard
end

# Task Management (for Admins)
post '/tasks' do
  require_admin_login

  task = Task.new(
    title: params[:title],
    description: params[:description],
    difficulty: params[:difficulty],
    category: params[:category],
    member_id: params[:member_id],
    due_date: params[:due_date],
    points: params[:points] || 1
  )

  if task.save
    set_flash('success', 'Task created successfully!')
  else
    set_flash('error', 'Error creating task')
  end
  redirect '/dashboard'
end

put '/tasks/:id/status' do
  task = Task.find(params[:id])

  # Allow admin or the assigned member to move tasks
  unless admin_logged_in? || (member_selected? && task.member_id == current_member.id)
    halt 403, { success: false, message: 'Permission denied' }.to_json
  end

  task.update(status: params[:status])

  content_type :json
  { success: true, task_id: task.id, status: task.status }.to_json
end

post '/tasks/:id/complete' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  unless task.member_id == current_member.id
    set_flash('error', 'You can only complete your own tasks')
    redirect '/dashboard'
  end

  TaskCompletion.create!(task: task, member: current_member, completed_at: Time.now, notes: params[:notes])
  task.update(status: 'done')

  set_flash('success', "Task completed! +#{task.points} points")
  redirect '/dashboard'
end

post '/tasks/:id/skip' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  unless task.member_id == current_member.id
    set_flash('error', 'You can only skip your own tasks')
    redirect '/dashboard'
  end

  TaskSkip.create!(task: task, member: current_member, skipped_at: Time.now, reason: params[:reason])
  task.update(status: 'skipped')

  set_flash('warning', 'Task skipped with reason recorded')
  redirect '/dashboard'
end

# Member Management (for Admins)
get '/members' do
  require_admin_login
  @members = Member.all
  erb :members
end

post '/members' do
  require_admin_login

  member = Member.new(name: params[:name], avatar_url: params[:avatar_url])

  if member.save
    set_flash('success', 'Member created successfully!')
  else
    set_flash('error', 'Error creating member')
  end
  redirect '/members'
end

# Reporting (for Admins)
get '/reports' do
  require_admin_login

  @members = Member.where(active: true)
  @period = params[:period] || '30'
  @start_date = @period.to_i.days.ago

  @member_stats = @members.map do |member|
    {
      member: member,
      points: calculate_member_points(member, @start_date),
      skips: calculate_member_skips(member, @start_date),
      completions: member.task_completions.where('completed_at >= ?', @start_date).count,
      completion_rate: calculate_completion_rate(member, @start_date)
    }
  end

  erb :reports
end

# --- Seed Data ---
if Admin.count == 0
  Admin.create!(
    username: 'admin',
    password_digest: BCrypt::Password.create('admin123')
  )
  puts "Created admin user: admin/admin123"
end

if Member.count == 0
  Member.create!([
    { name: 'Dad', avatar_url: 'https://i.pravatar.cc/150?u=dad' },
    { name: 'Mom', avatar_url: 'https://i.pravatar.cc/150?u=mom' },
    { name: 'Kid 1', avatar_url: 'https://i.pravatar.cc/150?u=kid1' }
  ])
  puts "Created sample members."
end
