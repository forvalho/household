require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'json'
require 'date'

# Database configuration
set :database, { adapter: 'sqlite3', database: 'household.db' }

# Enable sessions
enable :sessions

# Models
class User < ActiveRecord::Base
  has_many :tasks
  has_many :task_completions
  has_many :task_skips

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def is_admin?
    role == 'admin'
  end

  def can_manage_user?(other_user)
    is_admin? || id == other_user.id
  end
end

class Task < ActiveRecord::Base
  belongs_to :user
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
  belongs_to :user

  validates :completed_at, presence: true
end

class TaskSkip < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  validates :reason, presence: true
  validates :skipped_at, presence: true
end

# Create tables if they don't exist
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :username, null: false
    t.string :email, null: false
    t.string :password_digest, null: false
    t.string :role, default: 'user'
    t.string :name
    t.integer :age
    t.boolean :active, default: true
    t.timestamps
  end

  create_table :tasks, force: true do |t|
    t.string :title, null: false
    t.text :description
    t.string :status, default: 'todo'
    t.string :difficulty, default: 'medium'
    t.string :category
    t.integer :user_id
    t.date :due_date
    t.integer :points, default: 1
    t.timestamps
  end

  create_table :task_completions, force: true do |t|
    t.integer :task_id, null: false
    t.integer :user_id, null: false
    t.datetime :completed_at, null: false
    t.text :notes
    t.timestamps
  end

  create_table :task_skips, force: true do |t|
    t.integer :task_id, null: false
    t.integer :user_id, null: false
    t.datetime :skipped_at, null: false
    t.text :reason, null: false
    t.timestamps
  end
end

# Helper methods
helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    redirect '/login' unless logged_in?
  end

  def require_admin
    require_login
    redirect '/dashboard' unless current_user.is_admin?
  end

  def format_date(date)
    date.strftime('%B %d, %Y') if date
  end

  def calculate_user_points(user, start_date = 30.days.ago)
    completions = user.task_completions.joins(:task)
                      .where('completed_at >= ?', start_date)
    completions.sum { |tc| tc.task.points_value }
  end

  def calculate_user_skips(user, start_date = 30.days.ago)
    user.task_skips.where('skipped_at >= ?', start_date).count
  end

  # Flash message helpers
  def flash_message
    session.delete(:flash) if session[:flash]
  end

  def set_flash(type, message)
    session[:flash] = { type: type, message: message }
  end
end

# Routes
get '/' do
  redirect '/dashboard'
end

# Authentication
get '/login' do
  erb :login
end

post '/login' do
  user = User.find_by(username: params[:username])
  if user && BCrypt::Password.new(user.password_digest) == params[:password]
    session[:user_id] = user.id
    set_flash('success', "Welcome back, #{user.name}!")
    redirect '/dashboard'
  else
    set_flash('error', 'Invalid username or password')
    redirect '/login'
  end
end

get '/logout' do
  session.clear
  set_flash('success', 'You have been logged out')
  redirect '/login'
end

# Dashboard - Kanban Board
get '/dashboard' do
  require_login

  @tasks = Task.includes(:user).order(:created_at)
  @users = User.where(active: true)

  erb :dashboard
end

# Task Management
post '/tasks' do
  require_login

  task = Task.new(
    title: params[:title],
    description: params[:description],
    difficulty: params[:difficulty],
    category: params[:category],
    user_id: params[:user_id],
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
  require_login

  task = Task.find(params[:id])

  # Check permissions
  unless current_user.is_admin? || task.user_id == current_user.id
    set_flash('error', 'You can only move your own tasks')
    redirect '/dashboard'
  end

  task.update(status: params[:status])

  content_type :json
  { success: true, task_id: task.id, status: task.status }.to_json
end

post '/tasks/:id/complete' do
  require_login

  task = Task.find(params[:id])

  unless task.user_id == current_user.id
    set_flash('error', 'You can only complete your own tasks')
    redirect '/dashboard'
  end

  TaskCompletion.create!(
    task: task,
    user: current_user,
    completed_at: Time.current,
    notes: params[:notes]
  )

  task.update(status: 'done')

  set_flash('success', "Task completed! +#{task.points_value} points")
  redirect '/dashboard'
end

post '/tasks/:id/skip' do
  require_login

  task = Task.find(params[:id])

  unless task.user_id == current_user.id
    set_flash('error', 'You can only skip your own tasks')
    redirect '/dashboard'
  end

  TaskSkip.create!(
    task: task,
    user: current_user,
    skipped_at: Time.current,
    reason: params[:reason]
  )

  task.update(status: 'skipped')

  set_flash('warning', 'Task skipped with reason recorded')
  redirect '/dashboard'
end

# User Management
get '/users' do
  require_admin
  @users = User.all
  erb :users
end

post '/users' do
  require_admin

  user = User.new(
    username: params[:username],
    email: params[:email],
    name: params[:name],
    age: params[:age],
    role: params[:role] || 'user',
    password_digest: BCrypt::Password.create(params[:password])
  )

  if user.save
    set_flash('success', 'User created successfully!')
  else
    set_flash('error', 'Error creating user')
  end

  redirect '/users'
end

# Reporting
get '/reports' do
  require_login

  @users = User.where(active: true)
  @period = params[:period] || '30'
  @start_date = @period.to_i.days.ago

  @user_stats = @users.map do |user|
    {
      user: user,
      points: calculate_user_points(user, @start_date),
      skips: calculate_user_skips(user, @start_date),
      completions: user.task_completions.where('completed_at >= ?', @start_date).count,
      completion_rate: calculate_completion_rate(user, @start_date)
    }
  end

  erb :reports
end

def calculate_completion_rate(user, start_date)
  total_tasks = user.tasks.where('created_at >= ?', start_date).count
  completed_tasks = user.task_completions.joins(:task)
                        .where('completed_at >= ?', start_date).count

  return 0 if total_tasks == 0
  (completed_tasks.to_f / total_tasks * 100).round(1)
end

# API endpoints for AJAX
get '/api/tasks' do
  require_login

  tasks = Task.includes(:user).order(:created_at)

  content_type :json
  tasks.map do |task|
    {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      difficulty: task.difficulty,
      category: task.category,
      points: task.points,
      due_date: task.due_date&.strftime('%Y-%m-%d'),
      user: {
        id: task.user.id,
        name: task.user.name,
        username: task.user.username
      },
      created_at: task.created_at.strftime('%Y-%m-%d')
    }
  end.to_json
end

# Initialize with admin user if none exists
if User.count == 0
  User.create!(
    username: 'admin',
    email: 'admin@household.com',
    name: 'Administrator',
    role: 'admin',
    password_digest: BCrypt::Password.create('admin123')
  )
  puts "Created admin user: admin/admin123"
end
