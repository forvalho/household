class Task < ActiveRecord::Base
  belongs_to :member, optional: true
  has_many :task_completions, dependent: :destroy
  has_many :task_skips, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[unassigned todo in_progress done skipped], message: "%{value} is not a valid status" }
  validates :difficulty, inclusion: { in: %w[bronze silver gold] }

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
end
