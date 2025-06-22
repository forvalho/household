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

  namespace :data do
    desc "Run all data migrations in db/data/"
    task :migrate => :environment do
      data_files = Dir[File.join(__dir__, 'db', 'data', '*.rb')].sort

      # Extract version from filename (e.g., 20240611235000 from 20240611235000_migrate_category_data.rb)
      def extract_version(filename)
        File.basename(filename)[/^\d{14}/]
      end

      run_versions = ActiveRecord::Base.connection.select_values("SELECT version FROM data_migrations")

      if data_files.empty?
        puts "✅ No data migration files found in db/data/"
      else
        puts "Found #{data_files.count} data migration files:"
        data_files.each { |file| puts "  - #{File.basename(file)}" }
        puts ""

        pending_migrations = data_files.reject { |file| run_versions.include?(extract_version(file)) }

        if pending_migrations.empty?
          puts "✅ All data migrations have already been run!"
        else
          puts "Running #{pending_migrations.count} pending migrations:"
          pending_migrations.each { |file| puts "  - #{File.basename(file)}" }
          puts ""

          pending_migrations.each do |file|
            version = extract_version(file)
            puts "Running data migration: #{File.basename(file)}"
            require file
            ActiveRecord::Base.connection.execute("INSERT INTO data_migrations (version) VALUES ('#{version}')")
            puts "✅ Completed: #{File.basename(file)}"
            puts ""
          end
          puts "🎉 All pending data migrations complete!"
        end
      end
    end

    desc "List all available data migrations"
    task :list => :environment do
      data_files = Dir[File.join(__dir__, 'db', 'data', '*.rb')].sort
      def extract_version(filename)
        File.basename(filename)[/^\d{14}/]
      end
      run_versions = ActiveRecord::Base.connection.select_values("SELECT version FROM data_migrations")

      if data_files.empty?
        puts "No data migration files found in db/data/"
      else
        puts "Available data migrations:"
        data_files.each_with_index do |file, index|
          version = extract_version(file)
          status = run_versions.include?(version) ? "✅ RUN" : "⏳ PENDING"
          puts "  #{index + 1}. #{File.basename(file)} (#{status})"
        end
        puts ""
        puts "Run migrations: #{run_versions.count}/#{data_files.count}"
      end
    end

    desc "Run a specific data migration by filename"
    task :run, [:filename] => :environment do |t, args|
      if args[:filename].nil?
        puts "❌ Please specify a filename: rake db:data:run[filename.rb]"
        exit 1
      end
      file_path = File.join(__dir__, 'db', 'data', args[:filename])
      def extract_version(filename)
        File.basename(filename)[/^\d{14}/]
      end
      run_versions = ActiveRecord::Base.connection.select_values("SELECT version FROM data_migrations")
      version = extract_version(args[:filename])
      if File.exist?(file_path)
        if run_versions.include?(version)
          puts "⚠️  Migration #{args[:filename]} (#{version}) has already been run!"
          puts "Use 'rake db:data:reset' to clear tracking and run again."
        else
          puts "Running data migration: #{args[:filename]}"
          require file_path
          ActiveRecord::Base.connection.execute("INSERT INTO data_migrations (version) VALUES ('#{version}')")
          puts "✅ Completed: #{args[:filename]}"
        end
      else
        puts "❌ Data migration file not found: #{file_path}"
        puts "Available files:"
        Dir[File.join(__dir__, 'db', 'data', '*.rb')].sort.each do |file|
          puts "  - #{File.basename(file)}"
        end
        exit 1
      end
    end

    desc "Reset data migration tracking (for development/testing)"
    task :reset => :environment do
      count = ActiveRecord::Base.connection.execute("DELETE FROM data_migrations")
      puts "✅ Data migration tracking reset. All migrations will be treated as pending."
    end

    desc "Show status of all data migrations"
    task :status => :environment do
      data_files = Dir[File.join(__dir__, 'db', 'data', '*.rb')].sort
      def extract_version(filename)
        File.basename(filename)[/^\d{14}/]
      end
      run_versions = ActiveRecord::Base.connection.select_values("SELECT version FROM data_migrations")
      if data_files.empty?
        puts "No data migration files found in db/data/"
      else
        puts "Data Migration Status:"
        puts "=" * 50
        data_files.each do |file|
          version = extract_version(file)
          status = run_versions.include?(version) ? "✅ RUN" : "⏳ PENDING"
          puts "#{status} #{File.basename(file)} (#{version})"
        end
        puts "=" * 50
        puts "Run: #{run_versions.count}/#{data_files.count}"
        puts "Pending: #{data_files.count - run_versions.count}/#{data_files.count}"
      end
    end
  end
end

# All other tasks will inherit from the default Rake tasks
# provided by sinatra-activerecord.
# To see a list of all available tasks, run `bundle exec rake -T`
