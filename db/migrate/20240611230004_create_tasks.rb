class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:tasks)
      create_table :tasks do |t|
        t.string :title, null: false
        t.text :description
        t.string :status, default: 'todo'
        t.string :difficulty, default: 'bronze'
        t.string :category
        t.integer :member_id
        t.integer :task_template_id
        t.date :due_date
        t.integer :points, default: 1
        t.timestamps
      end
    end
  end
end
