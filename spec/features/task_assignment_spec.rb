require 'spec_helper'

RSpec.describe 'Task Assignment', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member1) { Member.create!(name: 'Alice') }
  let!(:member2) { Member.create!(name: 'Bob') }
  let!(:task) { Task.create!(title: 'Test Task', recurrence: 'none') }

  context 'as an admin' do
    before do
      visit '/admin/login'
      fill_in 'Username', with: 'admin'
      fill_in 'Password', with: 'admin123'
      click_button 'Log In'
    end

    it 'can assign a task to a member' do
      visit '/dashboard'
      find("[data-task-id='#{task.id}'] .assignee-btn").click
      within("#assigneeModal-#{task.id}") do
        select 'Alice', from: 'Assign to:'
        click_button 'Update Assignee'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to eq(member1)
    end

    it 'can unassign a task' do
      task.update(member: member1)
      visit '/dashboard'
      find("[data-task-id='#{task.id}'] .assignee-btn").click
      within("#assigneeModal-#{task.id}") do
        select 'Unassigned', from: 'Assign to:'
        click_button 'Update Assignee'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to be_nil
    end
  end

  context 'as a member' do
    before do
      visit "/members/#{member1.id}/select"
    end

    it 'can claim an unassigned task' do
      visit '/dashboard'
      find("[data-task-id='#{task.id}'] .assignee-btn").click
      within("#assigneeModal-#{task.id}") do
        click_button 'Assign to me'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to eq(member1)
    end

    it 'can unassign their own task' do
      task.update(member: member1)
      visit '/dashboard'
      find("[data-task-id='#{task.id}'] .assignee-btn").click
      within("#assigneeModal-#{task.id}") do
        click_button 'Unassign'
      end
      expect(page).to have_content('Task assignment updated!')
      expect(task.reload.member).to be_nil
    end

    it 'cannot assign a task to another member' do
      task.update(member: member2)
      visit '/dashboard'
      find("[data-task-id='#{task.id}'] .assignee-btn").click
      within("#assigneeModal-#{task.id}") do
        expect(page).to have_content('You cannot reassign this task.')
      end
    end
  end
end
