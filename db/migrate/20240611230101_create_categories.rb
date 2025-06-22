class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:categories)
      create_table :categories do |t|
        t.string :name, null: false
        t.timestamps
      end
    end
  end
end
