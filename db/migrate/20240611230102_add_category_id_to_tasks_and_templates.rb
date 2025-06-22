class AddCategoryIdToTasksAndTemplates < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:tasks, :category_id)
      add_column :tasks, :category_id, :integer
    end
    unless column_exists?(:task_templates, :category_id)
      add_column :task_templates, :category_id, :integer
    end
  end
end
