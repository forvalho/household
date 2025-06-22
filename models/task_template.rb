class TaskTemplate < ActiveRecord::Base
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
    if generic_task? && custom_title.present?
      # For Generic Task, use the custom title and difficulty
      Task.create!(
        title: custom_title,
        description: description,
        difficulty: custom_difficulty || difficulty,
        category: category,
        member: member,
        status: 'todo'
      )
    else
      # For regular templates, use the template's values
      Task.create!(
        title: title,
        description: description,
        difficulty: difficulty,
        category: category,
        member: member,
        status: 'todo'
      )
    end
  end
end
