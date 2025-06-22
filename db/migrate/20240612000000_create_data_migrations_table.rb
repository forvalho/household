class CreateDataMigrationsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :data_migrations, if_not_exists: true do |t|
      t.string :version, null: false
    end
    add_index :data_migrations, :version, unique: true
  end
end
