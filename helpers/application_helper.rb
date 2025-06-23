module ApplicationHelper
  AVATAR_BACKGROUND_COLORS = [
    '#f44336', '#e91e63', '#9c27b0', '#673ab7', '#3f51b5',
    '#2196f3', '#03a9f4', '#00bcd4', '#009688', '#4caf50',
    '#8bc34a', '#cddc39', '#ffeb3b', '#ffc107', '#ff9800',
    '#ff5722', '#795548', '#9e9e9e', '#607d8b'
  ].freeze

  AVATAR_STYLES = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=8',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=10',
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12'
  ].freeze

  # Flash message helpers
  def set_flash(type, message)
    session[:flash] = { type: type, message: message }
  end

  def flash_message
    session.delete(:flash)
  end

  # Authentication helpers
  def member_selected?
    session[:member_id].present?
  end

  def current_member
    @current_member ||= Member.find(session[:member_id]) if member_selected?
  end

  # Data helpers
  def format_date(date)
    date.strftime('%b %d, %Y')
  end

  def completed_today(member)
    member.task_completions.where('completed_at >= ?', Date.today.beginning_of_day).count
  end

  def total_points_today(member)
    member.task_completions.joins(:task)
           .where('task_completions.completed_at >= ?', Date.today.beginning_of_day)
           .sum { |tc| tc.task.points_value }
  end

  def pluralize(count, singular, plural = nil)
    "#{count} #{count == 1 ? singular : (plural || singular + 's')}"
  end

  # Text helper
  def truncate(text, length: 50)
    return text if text.length <= length
    text[0...length] + "..."
  end
end
