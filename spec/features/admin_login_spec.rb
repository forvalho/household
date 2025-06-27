require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Login', type: :feature, js: true do
  let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }

  before do
    admin # Instantiate the admin
  end

  it 'allows an admin to log in and see the dashboard' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'password'
    click_button 'Sign In'

    expect(page).to have_content('Tasks')
    expect(page).to have_content('Unassigned')
  end

  it 'shows an error with invalid credentials' do
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'wrong_password'
    click_button 'Sign In'

    expect(page).to have_content('Invalid admin username or password')
  end
end
