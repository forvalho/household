module ApplicationHelper
  AVATAR_BACKGROUND_COLORS = [
    '#f44336', '#e91e63', '#9c27b0', '#673ab7', '#3f51b5',
    '#2196f3', '#03a9f4', '#00bcd4', '#009688', '#4caf50',
    '#8bc34a', '#cddc39', '#ffeb3b', '#ffc107', '#ff9800',
    '#ff5722', '#795548', '#9e9e9e', '#607d8b'
  ].freeze

  AVATAR_STYLES = [
    'adventurer',
    'avataaars',
    'avataaars-neutral',
    'bottts',
    'croodles',
    'croodles-neutral',
    'identicon',
    'initials',
    'micah',
    'miniavs',
    'open-peeps',
    'personas',
    'pixel-art',
    'pixel-art-neutral',
    'shapes'
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

  # Full list of available DiceBear styles
  def all_dicebear_styles
    [
      'adventurer', 'adventurer-neutral', 'avataaars', 'avataaars-neutral',
      'big-ears', 'big-ears-neutral', 'big-smile', 'bottts', 'bottts-neutral',
      'croodles', 'croodles-neutral', 'fun-emoji', 'icons',
      'identicon', 'initials', 'lorelei', 'lorelei-neutral', 'micah', 'miniavs',
      'notionists', 'notionists-neutral', 'open-peeps', 'personas',
      'pixel-art', 'pixel-art-neutral', 'rings', 'shapes', 'thumbs'
    ]
  end

  # Default enabled styles (safe, popular, and legacy)
  def default_enabled_avatar_styles
    [
      'adventurer', 'avataaars', 'avataaars-neutral', 'bottts', 'croodles',
      'croodles-neutral', 'identicon', 'initials', 'micah', 'miniavs',
      'open-peeps', 'personas', 'pixel-art', 'pixel-art-neutral', 'shapes'
    ]
  end

  # Returns the enabled avatar styles from settings, or the default if not set
  def enabled_avatar_styles
    styles = Setting.get('enabled_avatar_styles')
    if styles.present?
      JSON.parse(styles)
    else
      default_enabled_avatar_styles
    end
  end

  # Returns a hash: style => count of members using that style
  def avatar_style_in_use_counts
    counts = Hash.new(0)
    Member.where.not(avatar_url: [nil, '']).find_each do |member|
      if member.avatar_url =~ /api\.dicebear\.com\/8\.x\/([\w-]+)\//
        style = $1
        counts[style] += 1
      end
    end
    counts
  end
end
