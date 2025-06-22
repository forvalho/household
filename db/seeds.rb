# Seed admin users
Admin.find_or_create_by!(username: 'admin') do |admin|
  admin.password_digest = BCrypt::Password.create('admin123')
  puts " -> Created admin user: admin/admin123"
end
puts "✅ Admin seeding complete!"

# Seed household members
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

# Create categories first
categories = {
  'General' => Category.find_or_create_by!(name: 'General'),
  'Kitchen' => Category.find_or_create_by!(name: 'Kitchen'),
  'Laundry' => Category.find_or_create_by!(name: 'Laundry'),
  'Yard' => Category.find_or_create_by!(name: 'Yard')
}

# Seed task templates
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
