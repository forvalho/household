require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Login', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }

  before do
    # Clear any existing sessions
    Capybara.current_session.driver.browser.clear_cookies
  end

  it 'allows an admin to log in and see the dashboard' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'password'
    click_button 'Sign In'

    expect(page).to have_current_path('/admin/dashboard')
    expect(page).to have_content('Tasks') # A key element on the dashboard
  end

  it 'shows an error with invalid credentials' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'wrongpassword'
    click_button 'Sign In'

    expect(page).to have_current_path('/admin/login')
  end
end
