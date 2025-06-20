require 'spec_helper'

RSpec.describe 'Task Status Changes', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('admin123')) }
  let!(:member) { Member.create!(name: 'Alice') }

  context 'as an admin' do
    before do
      visit '/admin/login'
      fill_in 'username', with: 'admin'
      fill_in 'password', with: 'admin123'
      click_button 'Sign In'
    end

    it 'can change a task from todo to in_progress' do
      task = Task.create!(title: 'Admin Task', status: 'todo', member: member)
      visit '/admin/dashboard'

      find("[data-task-id='#{task.id}'] .action-dropdown .dropdown-toggle").click
      click_button 'In Progress'

      expect(task.reload.status).to eq('in_progress')
    end
  end

  context 'as a member' do
    before do
      visit "/members/#{member.id}/select"
    end

    it 'can change their own task from todo to in_progress' do
      task = Task.create!(title: 'Member Task', status: 'todo', member: member)
      visit '/dashboard'

      find("[data-task-id='#{task.id}'] .action-dropdown .dropdown-toggle").click
      click_button 'In Progress'

      expect(task.reload.status).to eq('in_progress')
    end

    it 'cannot change an unassigned task' do
      task = Task.create!(title: 'Unassigned Task', status: 'unassigned')
      visit '/dashboard'

      find("[data-task-id='#{task.id}'] .action-dropdown .dropdown-toggle").click
      expect(page).to have_button('In Progress', disabled: true)
    end

    it 'cannot see tasks assigned to other members' do
      other_member = Member.create!(name: 'Bob')
      Task.create!(title: 'Bobs Task', status: 'todo', member: other_member)
      visit '/dashboard'

      expect(page).not_to have_content('Bobs Task')
    end
  end
end
