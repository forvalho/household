# models/category.rb
class Category < ActiveRecord::Base
  has_many :tasks
  has_many :task_templates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :icon, presence: true
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }

  # Available icons for categories
  AVAILABLE_ICONS = [
    'folder', 'home', 'kitchen-set', 'broom', 'spray-can', 'soap', 'shirt', 'bed',
    'car', 'bicycle', 'leaf', 'recycle', 'trash', 'tools', 'hammer', 'wrench',
    'paint-brush', 'palette', 'music', 'book', 'graduation-cap', 'laptop',
    'gamepad', 'tv', 'phone', 'wifi', 'lightbulb', 'plug', 'battery-full',
    'thermometer-half', 'snowflake', 'sun', 'cloud', 'umbrella', 'heart',
    'star', 'gift', 'birthday-cake', 'calendar', 'clock', 'stopwatch',
    'trophy', 'medal', 'crown', 'gem', 'diamond', 'coins', 'credit-card',
    'shopping-cart', 'store', 'tag', 'percent', 'calculator', 'chart-line',
    'chart-pie', 'chart-bar', 'users', 'user-friends', 'user-graduate',
    'user-tie', 'user-ninja', 'user-astronaut', 'user-cowboy', 'user-check',
    'user-clock', 'user-cog', 'user-edit', 'user-gear', 'user-graduate',
    'user-lock', 'user-minus', 'user-plus', 'user-secret', 'user-shield',
    'user-slash', 'user-times', 'user-xmark', 'baby', 'child', 'person',
    'person-biking', 'person-booth', 'person-breastfeeding', 'person-burst',
    'person-cane', 'person-chalkboard', 'person-circle-check', 'person-circle-exclamation',
    'person-circle-minus', 'person-circle-plus', 'person-circle-question',
    'person-circle-xmark', 'person-digging', 'person-dots-from-line',
    'person-dress', 'person-dress-burst', 'person-drowning', 'person-falling',
    'person-falling-burst', 'person-half-dress', 'person-harassing', 'person-hiking',
    'person-military-pointing', 'person-military-rifle', 'person-military-to-person',
    'person-praying', 'person-pregnant', 'person-rays', 'person-rifle',
    'person-running', 'person-shelter', 'person-skating', 'person-skiing',
    'person-skiing-nordic', 'person-sledding', 'person-snowboarding',
    'person-snowmobiling', 'person-swimming', 'person-through-window',
    'person-walking', 'person-walking-arrow-loop-left', 'person-walking-arrow-right',
    'person-walking-dashed-line-arrow-right', 'person-walking-luggage',
    'person-walking-with-cane', 'person-walking-with-crutch', 'person-walking-with-walker'
  ].freeze

  # Default color palette for categories
  DEFAULT_COLORS = [
    '#6c757d', '#dc3545', '#fd7e14', '#ffc107', '#198754', '#0d6efd',
    '#6f42c1', '#d63384', '#20c997', '#0dcaf0', '#6610f2', '#fd7e14',
    '#e83e8c', '#6f42c1', '#20c997', '#198754', '#ffc107', '#fd7e14',
    '#dc3545', '#6c757d', '#495057', '#343a40', '#212529', '#f8f9fa'
  ].freeze

  # Returns the icon class for FontAwesome
  def icon_class
    "fas fa-#{icon}"
  end

  # Returns the display name with icon
  def display_name_with_icon
    "<i class=\"#{icon_class}\" style=\"color: #{color}\"></i> #{name}"
  end

  # Returns the display name with icon and color styling
  def display_name_with_style
    "<span style=\"color: #{color}\"><i class=\"#{icon_class}\"></i> #{name}</span>"
  end

  # Returns a badge with the category styling
  def styled_badge
    "<span class=\"badge\" style=\"background-color: #{color}; color: white;\"><i class=\"#{icon_class}\"></i> #{name}</span>"
  end

  # Returns the category color with fallback
  def safe_color
    color.present? ? color : '#6c757d'
  end

  # Returns the category icon with fallback
  def safe_icon
    icon.present? ? icon : 'folder'
  end
end
