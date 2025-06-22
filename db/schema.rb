ActiveRecord::Schema.define do
  create_table :admins, if_not_exists: true do |t|
    t.string :username, null: false
    t.string :password_digest, null: false
    t.timestamps
  end

  create_table :members, if_not_exists: true do |t|
    t.string :name, null: false
    t.string :avatar_url
    t.boolean :active, default: true
    t.timestamps
  end

  create_table :task_templates, if_not_exists: true do |t|
    t.string :title, null: false
    t.text :description
    t.string :difficulty, default: 'bronze'
    t.string :category, null: false
    t.timestamps
  end

  create_table :tasks, if_not_exists: true do |t|
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

  create_table :task_completions, if_not_exists: true do |t|
    t.integer :task_id, null: false
    t.integer :member_id, null: false
    t.datetime :completed_at, null: false
    t.text :notes
    t.timestamps
  end
end
