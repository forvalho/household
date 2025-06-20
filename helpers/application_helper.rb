module ApplicationHelper
  # Flash message helpers
  def set_flash(key, message)
    session[:flash] ||= {}
    session[:flash][key] = message
  end

  def get_flash
    flash = session[:flash]
    session[:flash] = nil
    flash
  end

  # Authentication helpers
  def admin_logged_in?
    !session[:admin_id].nil?
  end

  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

  def member_selected?
    !session[:member_id].nil?
  end

  def current_member
    @current_member ||= Member.find(session[:member_id]) if session[:member_id]
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
           .sum('tasks.points')
  end

  def pluralize(count, singular, plural = nil)
    "#{count} #{count == 1 ? singular : (plural || singular + 's')}"
  end
end
