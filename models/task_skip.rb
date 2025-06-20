class TaskSkip < ActiveRecord::Base
  belongs_to :task
  belongs_to :member
  validates :skipped_at, presence: true
end
