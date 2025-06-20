require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require 'bcrypt'
require 'json'
require 'date'
require 'digest/md5'

# Require all Ruby files in a directory, sorted alphabetically
def require_all(dir)
  Dir.glob(File.join(__dir__, dir, '*.rb')).sort.each { |file| require file }
end

require_all('models')
require_all('helpers')
require_all('routes')

AVATAR_STYLES = [
  "adventurer", "adventurer-neutral", "avataaars", "avataaars-neutral", "big-ears",
  "big-ears-neutral", "big-smile", "bottts", "bottts-neutral", "croodles",
  "croodles-neutral", "fun-emoji", "icons", "identicon", "initials", "lorelei",
  "lorelei-neutral", "micah", "miniavs", "open-peeps", "personas", "pixel-art",
  "pixel-art-neutral", "shapes", "thumbs"
].freeze

AVATAR_BACKGROUND_COLORS = [
  '#ffffff', '#e0e0e0', '#616161', '#212121',
  '#f44336', '#e91e63', '#9c27b0', '#673ab7',
  '#3f51b5', '#2196f3', '#03a9f4', '#00bcd4',
  '#4caf50', '#8bc34a', '#ffeb3b', '#ff9800'
].freeze

# Database configuration
configure :development do
  set :database, { adapter: 'sqlite3', database: 'household.db' }
end

configure :test do
  set :database, { adapter: 'sqlite3', database: 'household_test.db' }
end

# Enable sessions
enable :sessions

# Set the main views directory only
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

  def calculate_member_skips(member, start_date = 30.days.ago)
    member.task_skips.where('skipped_at >= ?', start_date).count
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

# --- Routes ---

# Homepage (Profile selection)
get '/' do
  session.clear
  @members = Member.where(active: true).order(:name)
  erb :index
end

# Leaderboard page
get '/leaderboard' do
  @period = params[:period] || '30'
  @start_date = @period.to_i.days.ago
  @members = Member.where(active: true)

  @leaderboard_stats = @members.map do |member|
    {
      member: member,
      points: calculate_member_points(member, @start_date),
      medals: calculate_member_medals(member, @start_date),
      completions: member.task_completions.where('completed_at >= ?', @start_date).count
    }
  end

  # Calculate Performance Score
  max_points = @leaderboard_stats.map { |s| s[:points] }.max.to_f
  @leaderboard_stats.each do |stat|
    stat[:performance_score] = max_points > 0 ? ((stat[:points] / max_points) * 100).round : 0
  end

  # Sort by points descending, then by completion rate
  @leaderboard_stats.sort_by! { |stat| [-stat[:points], -stat[:performance_score]] }

  erb :leaderboard
end

# Load schema first, then seed data
db_schema = File.join(__dir__, 'db', 'schema.rb')
load db_schema if File.exist?(db_schema)

load File.join(__dir__, 'db', 'seeds.rb')
