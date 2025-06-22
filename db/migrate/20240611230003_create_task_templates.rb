class CreateTaskTemplates < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:task_templates)
      create_table :task_templates do |t|
        t.string :title, null: false
        t.text :description
        t.string :difficulty, default: 'bronze'
        t.string :category, null: false
        t.timestamps
      end
    end
  end
end
