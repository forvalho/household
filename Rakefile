require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
Dir[File.join(__dir__, 'models', '*.rb')].sort.each { |file| require file }

task :environment do
  require_relative 'app'

  # Explicitly load all models, helpers, and routes
  ['models', 'helpers', 'routes'].each do |dir|
    Dir[File.join(__dir__, dir, '**', '*.rb')].sort.each { |file| require file }
  end
end

namespace :db do
  desc "Migrate string categories to a separate Category model"
  task :migrate_categories => :environment do
    puts "Starting category migration..."
    all_category_names = (Task.distinct.pluck(:category) + TaskTemplate.distinct.pluck(:category)).compact.uniq.sort

    if all_category_names.empty?
      puts "✅ No categories to migrate."
    else
      puts "Found #{all_category_names.count} unique categories to migrate: #{all_category_names.join(', ')}"
      all_category_names.each { |name| Category.find_or_create_by!(name: name) }
      puts "✅ Created Category records."

      category_map = Category.all.index_by(&:name)
      puts "Updating tasks and task_templates with new category_id..."
      category_map.each do |name, category|
        Task.where(category: name).update_all(category_id: category.id)
        TaskTemplate.where(category: name).update_all(category_id: category.id)
      end
      puts "✅ Data migration complete. You should now remove the old 'category' columns from your schema."
    end
  end

  desc "Backfill task_template_id for existing tasks based on title"
  task :backfill_task_template_ids => :environment do
    puts "Starting to backfill task_template_id for existing tasks..."

    tasks_to_update = Task.where(task_template_id: nil)

    if tasks_to_update.empty?
      puts "✅ No tasks to update. All tasks seem to be correctly associated."
    else
      puts "Found #{tasks_to_update.count} tasks with missing template associations."
      tasks_grouped_by_title = tasks_to_update.group_by(&:title)
      templates_cache = TaskTemplate.all.index_by(&:title)
      updated_count = 0

      tasks_grouped_by_title.each do |title, tasks|
        template = templates_cache[title]
        if template
          task_ids = tasks.map(&:id)
          puts "-> Linking #{tasks.count} tasks with title '#{title}' to template ID #{template.id}."
          Task.where(id: task_ids).update_all(task_template_id: template.id)
          updated_count += tasks.count
        else
          puts "-> ⚠️ No matching template found for tasks with title '#{title}'. These will remain custom tasks."
        end
      end
      puts "\n✅ Backfill complete! Successfully updated #{updated_count} tasks."
    end
  end

  desc "Seed the database with all sample data"
  task :seed => ['db:seed:admins', 'db:seed:members', 'db:seed:tasks'] do
    puts "✅ All seeding complete!"
  end

  namespace :seed do
    desc "Seed admin users"
    task :admins => :environment do
      puts "Seeding admins..."
      Admin.find_or_create_by!(username: 'admin') do |admin|
        admin.password_digest = BCrypt::Password.create('admin123')
        puts " -> Created admin user: admin/admin123"
      end
      puts "✅ Admin seeding complete!"
    end

    desc "Seed household members"
    task :members => :environment do
      puts "Seeding members..."
      [
        { name: 'Dad', avatar_url: 'https://i.pravatar.cc/150?u=dad' },
        { name: 'Mom', avatar_url: 'https://i.pravatar.cc/150?u=mom' },
        { name: 'Kid 1', avatar_url: 'https://i.pravatar.cc/150?u=kid1' },
        { name: 'Kid 2', avatar_url: 'https://i.pravatar.cc/150?u=kid2' }
      ].each do |attrs|
        Member.find_or_create_by!(name: attrs[:name]) do |member|
          member.avatar_url = attrs[:avatar_url]
          puts " -> Created member: #{member.name}"
        end
      end
      puts "✅ Member seeding complete!"
    end

    desc "Seed sample task templates"
    task :tasks => :environment do
      puts "Seeding task templates..."

      # Create categories first
      categories = {
        'General' => Category.find_or_create_by!(name: 'General'),
        'Kitchen' => Category.find_or_create_by!(name: 'Kitchen'),
        'Laundry' => Category.find_or_create_by!(name: 'Laundry'),
        'Yard' => Category.find_or_create_by!(name: 'Yard')
      }

      [
        { title: 'Generic Task', difficulty: 'bronze', category: categories['General'], description: 'A customizable task for any household chore' },
        { title: 'Fill and start dishwasher', difficulty: 'silver', category: categories['Kitchen'] },
        { title: 'Empty dishwasher', difficulty: 'bronze', category: categories['Kitchen'] },
        { title: 'Collect dirty laundry', difficulty: 'bronze', category: categories['Laundry'] },
        { title: 'Wash laundry', difficulty: 'bronze', category: categories['Laundry'] },
        { title: 'Hang laundry', difficulty: 'bronze', category: categories['Laundry'] },
        { title: 'Fold laundry', difficulty: 'silver', category: categories['Laundry'] },
        { title: 'Put away laundry', difficulty: 'silver', category: categories['Laundry'] },
        { title: 'Gardening', difficulty: 'gold', category: categories['Yard'] },
        { title: 'Water backyard', difficulty: 'bronze', category: categories['Yard'] },
        { title: 'Water frontyard', difficulty: 'bronze', category: categories['Yard'] },
      ].each do |attrs|
        template = TaskTemplate.find_or_initialize_by(title: attrs[:title])
        template.difficulty = attrs[:difficulty]
        template.category = attrs[:category]
        template.description = attrs[:description] if attrs[:description]
        template.save!
        puts " -> Created/updated task template: #{template.title}"
      end
      puts "✅ Task template seeding complete!"
    end
  end
end

# All other tasks will inherit from the default Rake tasks
# provided by sinatra-activerecord.
# To see a list of all available tasks, run `bundle exec rake -T`
