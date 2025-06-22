namespace :db do
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

    desc "Seed sample tasks"
    task :tasks do
      require_relative 'app'
      puts "Seeding tasks..."

      # Upsert Tasks
      [
        { title: 'Fill and start dishwasher', difficulty: 'silver', category: 'Kitchen' },
        { title: 'Empty dishwasher', difficulty: 'bronze', category: 'Kitchen' },
        { title: 'Hang laundry', difficulty: 'bronze', category: 'Laundry' },
        { title: 'Fold laundry', difficulty: 'silver', category: 'Laundry' },
        { title: 'Put away laundry', difficulty: 'silver', category: 'Laundry' },
        { title: 'Mow lawn', difficulty: 'gold', category: 'Yard' },
        { title: 'Water backyard', difficulty: 'bronze', category: 'Yard' },
        { title: 'Water frontyard', difficulty: 'bronze', category: 'Yard' }
      ].each do |attrs|
        task = Task.find_or_initialize_by(title: attrs[:title])
        task.difficulty = attrs[:difficulty]
        task.category = attrs[:category]
        task.status ||= 'unassigned' # Set status only if it's a new record
        task.save!
        puts " -> Created/updated task: #{task.title}"
      end

      puts "✅ Task seeding complete!"
    end
  end
end
