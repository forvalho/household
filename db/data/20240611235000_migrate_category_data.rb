class MigrateCategoryData < ActiveRecord::Migration[6.1]
  def up
    # Only run this migration if the old category columns exist
    if (Task.column_names.include?('category') || TaskTemplate.column_names.include?('category'))
      puts "Starting category data migration..."
      old_task_categories = Task.distinct.pluck(:category).compact
      old_template_categories = TaskTemplate.distinct.pluck(:category).compact
      all_category_names = (old_task_categories + old_template_categories).uniq.sort

      if all_category_names.empty?
        puts "✅ No categories to migrate."
        return
      end

      puts "Found #{all_category_names.count} unique categories to migrate: #{all_category_names.join(', ')}"
      all_category_names.each { |name| Category.find_or_create_by!(name: name) }
      puts "✅ Created Category records."

      category_map = Category.all.index_by(&:name)
      puts "Updating tasks and task_templates with new category_id..."
      category_map.each do |name, category|
        Task.where(category: name).update_all(category_id: category.id)
        TaskTemplate.where(category: name).update_all(category_id: category.id)
      end
      puts "✅ Data migration complete."
    end
  end

  def down
    # Not reversible
    raise ActiveRecord::IrreversibleMigration, "Cannot reverse category data migration - data would be lost"
  end
end
