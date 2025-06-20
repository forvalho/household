class Task < ActiveRecord::Base
  belongs_to :member, optional: true
  has_many :task_completions, dependent: :destroy
  has_many :task_skips, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[unassigned todo in_progress done skipped], message: "%{value} is not a valid status" }
  validates :difficulty, inclusion: { in: %w[easy medium hard] }
  validates :recurrence, inclusion: { in: %w[none daily weekly], message: "%{value} is not a valid recurrence" }

  def points_value
    case difficulty
    when 'easy' then 1
    when 'medium' then 2
    when 'hard' then 3
    else 1
    end
  end

  # A task is considered completed for the day if a completion record exists for it today.
  def completed_today?
    task_completions.where("DATE(completed_at) = ?", Date.today).exists?
  end
end
