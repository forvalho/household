class CreateTaskCompletions < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:task_completions)
      create_table :task_completions do |t|
        t.integer :task_id, null: false
        t.integer :member_id, null: false
        t.datetime :completed_at, null: false
        t.text :notes
        t.timestamps
      end
    end
  end
end
