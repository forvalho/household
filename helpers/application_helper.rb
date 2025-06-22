module ApplicationHelper
  # Flash message helpers
  def set_flash(type, message)
    session[:flash] = { type: type, message: message }
  end

  def flash_message
    session.delete(:flash)
  end

  # Authentication helpers
  def admin_logged_in?
    session[:admin_id].present?
  end

  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

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

  def skipped_today(member)
    member.task_skips.where('skipped_at >= ?', Date.today.beginning_of_day).count
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
