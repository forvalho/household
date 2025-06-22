class TaskTemplate < ActiveRecord::Base
  has_many :tasks
  belongs_to :category

  validates :title, presence: true
  validates :difficulty, inclusion: { in: %w[bronze silver gold] }
  validates :category, presence: true

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

  def generic_task?
    title == 'Generic Task'
  end

  # Create a new task from this template for a specific member
  def create_task_for(member, custom_title: nil, custom_difficulty: nil)
    task_attributes = {
      description: description,
      category: category,
      member: member,
      status: 'todo',
      task_template: self # Link to this template
    }

    if generic_task? && custom_title.present?
      # For Generic Task, use the custom title and difficulty
      task_attributes.merge!(
        title: custom_title,
        difficulty: custom_difficulty || difficulty
      )
    else
      # For regular templates, use the template's values
      task_attributes.merge!(
        title: title,
        difficulty: difficulty
      )
    end

    Task.create!(task_attributes)
  end
end
