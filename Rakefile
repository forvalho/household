require 'sinatra/activerecord/rake'

namespace :db do
  desc "Backfill task_template_id for existing tasks based on title"
  task :backfill_task_template_ids => :environment do
    require_relative 'app'
    puts "Starting to backfill task_template_id for existing tasks..."

    # Find all tasks that don't have a template linked yet
    tasks_to_update = Task.where(task_template_id: nil)

    if tasks_to_update.empty?
      puts "✅ No tasks to update. All tasks seem to be correctly associated."
      next
    end

    puts "Found #{tasks_to_update.count} tasks with missing template associations."

    # Group tasks by title to reduce database queries
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

    puts "\n✅ Backfill complete!"
    puts "Successfully updated #{updated_count} tasks."
  end

  desc "Seed the database with all sample data"
  task :seed => ['db:seed:admins', 'db:seed:members', 'db:seed:tasks'] do
    puts "✅ All seeding complete!"
  end

  namespace :seed do
    desc "Seed admin users"
    task :admins do
      require_relative 'app'
      puts "Seeding admins..."

      # Upsert Admin
      Admin.find_or_create_by!(username: 'admin') do |admin|
        admin.password_digest = BCrypt::Password.create('admin123')
        puts " -> Created admin user: admin/admin123"
      end

      puts "✅ Admin seeding complete!"
    end

    desc "Seed household members"
    task :members do
      require_relative 'app'
      puts "Seeding members..."

      # Upsert Members
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
    task :tasks do
      require_relative 'app'
      puts "Seeding task templates..."

      # Upsert Task Templates
      [
        { title: 'Generic Task', difficulty: 'bronze', category: 'General', description: 'A customizable task for any household chore' },
        { title: 'Fill and start dishwasher', difficulty: 'silver', category: 'Kitchen' },
        { title: 'Empty dishwasher', difficulty: 'bronze', category: 'Kitchen' },
        { title: 'Collect dirty laundry', difficulty: 'bronze', category: 'Laundry' },
        { title: 'Wash laundry', difficulty: 'bronze', category: 'Laundry' },
        { title: 'Hang laundry', difficulty: 'bronze', category: 'Laundry' },
        { title: 'Fold laundry', difficulty: 'silver', category: 'Laundry' },
        { title: 'Put away laundry', difficulty: 'silver', category: 'Laundry' },
        { title: 'Gardening', difficulty: 'gold', category: 'Yard' },
        { title: 'Water backyard', difficulty: 'bronze', category: 'Yard' },
        { title: 'Water frontyard', difficulty: 'bronze', category: 'Yard' },
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
