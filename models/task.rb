class Task < ActiveRecord::Base
  belongs_to :member
  has_many :task_completions
  belongs_to :task_template, optional: true
  belongs_to :category

  validates :title, presence: true
  validates :member, presence: true
  validates :difficulty, inclusion: { in: %w[bronze silver gold] }
  validates :status, inclusion: { in: %w[todo in_progress done] }

  before_validation :set_default_status, on: :create

  def points_value
    case difficulty
    when 'bronze' then 1
    when 'silver' then 3
    when 'gold' then 5
    else 0
    end
  end

  def medal
    difficulty
  end

  # A task is considered completed for the day if a completion record exists for it today.
  def completed_today?
    task_completions.where("DATE(completed_at) = ?", Date.today).exists?
  end

  def set_default_status
    self.status = 'todo' if self.status.nil?
  end

  def custom_task?
    task_template_id.nil?
  end

  # State machine methods
  def valid_status_transitions
    case status
    when 'todo'
      %w[in_progress done]
    when 'in_progress'
      %w[done todo]
    when 'done'
      []
    else
      []
    end
  end

  def can_transition_to?(new_status)
    valid_status_transitions.include?(new_status)
  end

  def transition_to!(new_status)
    if can_transition_to?(new_status)
      update!(status: new_status)
    else
      raise ArgumentError, "Invalid transition from #{status} to #{new_status}"
    end
  end
end
