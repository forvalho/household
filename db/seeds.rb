# --- Seed Data ---

# Upsert Admin
Admin.find_or_create_by!(username: 'admin') do |admin|
  admin.password_digest = BCrypt::Password.create('admin123')
  puts "Created admin user: admin/admin123"
end

# Upsert Members
puts "Upserting members..."
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

# Upsert Tasks
puts "Upserting and updating sample tasks..."
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
end

puts "Seeding complete."
