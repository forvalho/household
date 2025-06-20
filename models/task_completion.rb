class TaskCompletion < ActiveRecord::Base
  belongs_to :task
  belongs_to :member
  validates :completed_at, presence: true
end
