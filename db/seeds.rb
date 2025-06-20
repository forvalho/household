# --- Seed Data ---
if Admin.count == 0
  Admin.create!(
    username: 'admin',
    password_digest: BCrypt::Password.create('admin123')
  )
  puts "Created admin user: admin/admin123"
end

if Member.count == 0
  Member.create!([
    { name: 'Dad', avatar_url: 'https://i.pravatar.cc/150?u=dad' },
    { name: 'Mom', avatar_url: 'https://i.pravatar.cc/150?u=mom' },
    { name: 'Kid 1', avatar_url: 'https://i.pravatar.cc/150?u=kid1' }
  ])
  puts "Created sample members."
end

# Seed unassigned tasks
if Task.count == 0
  tasks_to_create = [
    { title: 'Fill and start dishwasher', difficulty: 'medium', category: 'Kitchen' },
    { title: 'Empty dishwasher', difficulty: 'easy', category: 'Kitchen' },
    { title: 'Hang laundry', difficulty: 'easy', category: 'Laundry' },
    { title: 'Fold laundry', difficulty: 'medium', category: 'Laundry' },
    { title: 'Put away laundry', difficulty: 'medium', category: 'Laundry' },
    { title: 'Mow lawn', difficulty: 'hard', category: 'Yard' },
    { title: 'Water backyard', difficulty: 'easy', category: 'Yard' },
    { title: 'Water frontyard', difficulty: 'easy', category: 'Yard' }
  ]

  tasks_to_create.each do |task_attrs|
    Task.create!(task_attrs)
  end

  puts "Created sample unassigned tasks."
end
