class RemoveCategoryStringFromTasksAndTemplates < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:tasks, :category)
      remove_column :tasks, :category, :string
    end
    if column_exists?(:task_templates, :category)
      remove_column :task_templates, :category, :string
    end
  end
end
