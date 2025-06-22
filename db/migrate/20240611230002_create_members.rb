class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:members)
      create_table :members do |t|
        t.string :name, null: false
        t.string :avatar_url
        t.boolean :active, default: true
        t.timestamps
      end
    end
  end
end
