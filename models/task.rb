class Task < ActiveRecord::Base
  belongs_to :member
  has_many :task_completions, dependent: :destroy
  has_many :task_skips, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[todo in_progress done] }
  validates :difficulty, inclusion: { in: %w[easy medium hard] }

  def points_value
    case difficulty
    when 'easy' then 1
    when 'medium' then 2
    when 'hard' then 3
    else 1
    end
  end
end
