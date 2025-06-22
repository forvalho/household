require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require 'bcrypt'
require 'json'
require 'date'
require 'digest/md5'

# Load all application files
['models', 'helpers', 'routes'].each do |dir|
  Dir[File.join(__dir__, dir, '**', '*.rb')].sort.each { |file| require file }
end

class App < Sinatra::Base
  register Sinatra::Namespace
  register Sinatra::ActiveRecordExtension

  # Enable sessions
  enable :sessions

  # Set the main views directory
  set :views, File.join(__dir__, 'views')

  # Include helpers
  helpers ApplicationHelper
  helpers DataHelper

  # Additional helpers
  helpers do
    def require_admin_login
      redirect '/admin/login' unless admin_logged_in?
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

    # Helper to find a member or halt
    def find_member_or_halt(id)
      member = Member.find_by(id: id)
      halt 404, "Member not found" unless member
      member
    end

    def flash_message
      session.delete(:flash)
    end
  end
end
