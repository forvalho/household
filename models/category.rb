# models/category.rb
class Category < ActiveRecord::Base
  has_many :tasks
  has_many :task_templates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
