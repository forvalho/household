# db/data/20240612150000_ensure_admin_user_exists.rb

puts "--> Ensuring default admin user exists..."

# Read credentials from environment variables, with defaults.
admin_username = ENV.fetch('INITIAL_ADMIN_USERNAME', 'admin')
admin_password = ENV.fetch('INITIAL_ADMIN_PASSWORD', 'admin123')

if Admin.exists?(username: admin_username)
  puts "✅ Admin user '#{admin_username}' already exists. Skipping."
else
  puts "-> Admin user '#{admin_username}' not found. Creating..."
  Admin.create!(
    username: admin_username,
    password: admin_password,
    password_confirmation: admin_password
  )
  puts "✅ Default admin user '#{admin_username}' created."

  # Avoid printing credentials in production logs if they are set via ENV
  if ENV['INITIAL_ADMIN_PASSWORD']
    puts "🔑 Password was set from INITIAL_ADMIN_PASSWORD environment variable."
  else
    puts "🔑 Password is: #{admin_password}"
    puts "⚠️  IMPORTANT: Remember to change this password after your first login."
  end
end
