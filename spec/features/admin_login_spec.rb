require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Login', type: :feature do
  before do
    # Create a test admin user
    password_hash = BCrypt::Password.create('password123')
    Admin.create!(username: 'feature_admin', password_digest: password_hash)
  end

  it 'allows an admin to log in and see the dashboard' do
    visit '/admin/login'

    fill_in 'username', with: 'feature_admin'
    fill_in 'password', with: 'password123'
    click_button 'Sign In'

    expect(page).to have_current_path('/admin/dashboard')
    expect(page).to have_content('Tasks')
    expect(page).to have_content('Welcome back, Admin!')
  end

  it 'shows an error with invalid credentials' do
    visit '/admin/login'

    fill_in 'username', with: 'feature_admin'
    fill_in 'password', with: 'wrong_password'
    click_button 'Sign In'

    expect(page).to have_current_path('/admin/login')
    expect(page).to have_content('Invalid admin username or password')
  end
end
