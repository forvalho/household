require 'spec_helper'

RSpec.describe 'Task Assignment', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member1) { Member.create!(name: 'Alice', avatar_url: 'https://api.dicebear.com/8.x/initials/svg?seed=Alice') }
  let!(:member2) { Member.create!(name: 'Bob', avatar_url: 'https://api.dicebear.com/8.x/initials/svg?seed=Bob') }
  let!(:task) { Task.create!(title: 'Test Task', recurrence: 'none', status: 'unassigned') }

  def login_as_admin
    visit '/admin/login'
    fill_in 'Username', with: 'admin'
    fill_in 'Password', with: 'admin123'
    click_button 'Sign In'
    visit '/admin/dashboard'
  end

  def login_as_member(member)
    visit "/members/#{member.id}/select"
    visit '/dashboard'
  end

  context 'as an admin' do
    before { login_as_admin }

    it 'can assign a task to a member' do
      find("[data-task-id='#{task.id}'] .assignee-dropdown-btn").click
      within("[data-task-id='#{task.id}'] .assignee-dropdown-menu") do
        click_button 'Alice'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to eq(member1)
      expect(task.reload.status).to eq('todo') # Should change status
    end

    it 'can unassign a task' do
      task.update(member: member1, status: 'todo')
      visit '/admin/dashboard' # Re-visit to see the changes

      find("[data-task-id='#{task.id}'] .assignee-dropdown-btn").click
      within("[data-task-id='#{task.id}'] .assignee-dropdown-menu") do
        click_button 'Unassigned'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to be_nil
      expect(task.reload.status).to eq('unassigned')
    end
  end

  context 'as a member' do
    before { login_as_member(member1) }

    it 'can claim an unassigned task' do
      find("[data-task-id='#{task.id}'] .assignee-dropdown-btn").click
      within("[data-task-id='#{task.id}'] .assignee-dropdown-menu") do
        # Can assign to self
        expect(page.find('button', text: 'Alice')).not_to be_disabled
        # Cannot assign to others
        expect(page.find('button', text: 'Bob')).to be_disabled

        click_button 'Alice'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to eq(member1)
    end

    it 'can unassign themselves from a task' do
      task.update(member: member1, status: 'todo')
      visit '/dashboard'

      find("[data-task-id='#{task.id}'] .assignee-dropdown-btn").click
      within("[data-task-id='#{task.id}'] .assignee-dropdown-menu") do
        expect(page.find('button', text: 'Unassigned')).not_to be_disabled
        click_button 'Unassigned'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to be_nil
    end

    it 'cannot unassign another member' do
      task.update(member: member2, status: 'todo')
      # The task is for another member, so it won't appear on the board.
      # This test logic is sound but might be better as a request spec.
      visit '/dashboard'
      expect(page).not_to have_css("[data-task-id='#{task.id}']")
    end
  end
end
