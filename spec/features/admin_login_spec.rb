require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Login', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }

  before do
    # Clear any existing sessions
    Capybara.current_session.driver.browser.clear_cookies
  end

  xit 'allows an admin to log in and see the dashboard' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'admin123'
    click_button 'Log In'
    expect(page).to have_content('Admin Dashboard')
  end

  xit 'shows an error with invalid credentials' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'wrongpassword'
    click_button 'Log In'
    expect(page).to have_content('Invalid admin username or password')
  end
end
