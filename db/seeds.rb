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
