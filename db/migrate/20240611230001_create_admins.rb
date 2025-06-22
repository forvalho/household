class CreateAdmins < ActiveRecord::Migration[6.1]
  def change
    unless table_exists?(:admins)
      create_table :admins do |t|
        t.string :username, null: false
        t.string :password_digest, null: false
        t.timestamps
      end
    end
  end
end
