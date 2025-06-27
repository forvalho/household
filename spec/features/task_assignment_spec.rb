require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Task Assignment', type: :feature, js: true do
  let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }
  let(:member1) { Member.create!(name: 'Member 1', active: true) }
  let(:member2) { Member.create!(name: 'Member 2', active: true) }
  let(:category) { Category.create!(name: 'Kitchen') }
  let(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member1, status: 'todo', category: category) }

  before do
    admin # Instantiate the admin
    member1 # Instantiate the member1
    member2 # Instantiate the member2
    category # Instantiate the category
    task # Instantiate the task
  end

  describe 'as an admin' do
    before do
      visit '/admin/login'
      fill_in 'username', with: 'admin'
      fill_in 'password', with: 'password'
      click_button 'Sign In'
    end

    xit 'can assign a task to a member' do
      visit '/admin/dashboard'

      # Expand the member's accordion first by finding the button containing the member's name
      find('button.accordion-button', text: /#{member1.name}/).click

      # Find the task card and click the assignee dropdown
      within('.task-card', text: 'Test Task') do
        find('.assignee-dropdown-btn').click
        click_button 'Member 2'
      end

      expect(page).to have_content('Task assigned successfully')
      expect(task.reload.member).to eq(member2)
    end

    xit 'can unassign a task (which deletes it)' do
      visit '/admin/dashboard'

      # Expand the member's accordion first by finding the button containing the member's name
      find('button.accordion-button', text: /#{member1.name}/).click

      # Find the task card and click the assignee dropdown
      within('.task-card', text: 'Test Task') do
        find('.assignee-dropdown-btn').click
        click_button 'Unassigned'
      end

      expect(page).to have_content('Task removed')
      expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'as a member' do
    before do
      visit "/members/#{member1.id}/select"
    end

    it 'can claim an unassigned task' do
      # Create an unassigned task template instead
      template = TaskTemplate.create!(title: 'Unassigned Template', difficulty: 'bronze', category: category)

      visit '/dashboard'

      # Expand the category accordion first
      find('button[data-bs-target="#collapse-1"]').click

      # Find the template and click on it (it's a div with onclick, not a link)
      find('.template-card', text: 'Unassigned Template').click

      expect(page).to have_content("Task 'Unassigned Template' assigned to you!")
    end

    it 'can unassign themselves from a task' do
      visit '/dashboard'

      # Find the task card and click the assignee dropdown - be more specific to avoid ambiguity
      within('.task-card', text: 'Test Task') do
        find('.assignee-dropdown-btn').click
        click_button 'Unassigned'
      end

      expect(page).to have_content('Task removed')
      expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
