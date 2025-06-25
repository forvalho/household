class AddVisualCustomizationToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :icon, :string, default: 'folder'
    add_column :categories, :color, :string, default: '#6c757d'
  end
end
