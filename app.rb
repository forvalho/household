require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'sinatra/namespace'
require 'bcrypt'
require 'json'
require 'date'
require 'digest/md5'

# --- 1. Load dependent files (Models & Helpers) ---
['models', 'helpers'].each do |dir|
  Dir[File.join(__dir__, dir, '**', '*.rb')].sort.each { |file| require_relative file }
end

# --- 2. Define the main Application class ---
class App < Sinatra::Base
  register Sinatra::Namespace
  register Sinatra::ActiveRecordExtension

  # Configuration
  set :database_file, "config/database.yml"
  set :views, File.join(__dir__, 'views')
  enable :sessions

  # Helpers
  helpers ApplicationHelper
  helpers DataHelper

  # Local helpers
  helpers do
    def require_admin_login
      redirect '/admin/login' unless session[:admin_id]
    end

    def admin_logged_in?
      !!session[:admin_id]
    end

    def find_member_or_halt(id)
      member = Member.find_by(id: id)
      halt 404, "Member not found" unless member
      member
    end

    def flash_message
      session.delete(:flash)
    end

    def outstanding_tasks(member)
      member.tasks.where(status: ['todo', 'in_progress']).count
    end

    def calculate_member_points(member, start_date = 30.days.ago)
      completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
      completions.sum { |tc| tc.task.points_value }
    end

    def calculate_completion_rate(member, start_date)
      total_tasks = member.tasks.where('created_at >= ?', start_date).count
      completed_tasks = member.task_completions.joins(:task).where('completed_at >= ?', start_date).count
      return 0 if total_tasks == 0
      (completed_tasks.to_f / total_tasks * 100).round(1)
    end
  end

  # --- Routes ---
  get '/' do
    @members = Member.all.order(:name)
    erb :index
  end
end

# --- 3. Load the routes ---
Dir[File.join(__dir__, 'routes', '**', '*.rb')].sort.each { |file| require_relative file }

# Define a simple DataMigration model for Rake tasks
class DataMigration < ActiveRecord::Base
end rescue nil
