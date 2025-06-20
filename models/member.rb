class Member < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :tasks, dependent: :destroy
  has_many :task_completions, dependent: :destroy
  has_many :task_skips, dependent: :destroy
end
