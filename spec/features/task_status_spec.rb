require 'spec_helper'
require 'database_cleaner/active_record'

RSpec.describe 'Task Status Changes', type: :feature do
  before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member1) { Member.create!(name: 'Alice') }
  let!(:member2) { Member.create!(name: 'Bob') }

  def find_task_card(task)
    find(:css, ".task-card[data-task-id='#{task.id}']", text: task.title)
  end

  context 'as an admin' do
    before do
      visit '/admin/login'
      fill_in 'Username', with: 'admin'
      fill_in 'Password', with: 'admin123'
      click_button 'Sign In'
    end

    it 'can change task status to in progress' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member_id: nil)
      visit '/admin/dashboard'
      card = find_task_card(task)
      card.click_button 'In Progress'
      expect(task.reload.status).to eq('in_progress')
    end

    it 'can change task status to done' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member_id: nil)
      visit '/admin/dashboard'
      card = find_task_card(task)
      card.click_button 'Done'
      expect(task.reload.status).to eq('done')
    end

    it 'can change task status to skipped' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member_id: nil)
      visit '/admin/dashboard'
      card = find_task_card(task)
      card.click_button 'Skip'
      expect(task.reload.status).to eq('skipped')
    end
  end

  context 'as a member' do
    before do
      visit "/members/#{member1.id}/select"
    end

    it 'can change unassigned task status' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member_id: nil)
      visit '/dashboard'
      card = find_task_card(task)
      card.click_button 'In Progress'
      expect(task.reload.status).to eq('in_progress')
    end

    it 'can change their own task status' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member: member1)
      visit '/dashboard'
      card = find_task_card(task)
      card.click_button 'Done'
      expect(task.reload.status).to eq('done')
    end

    it 'cannot change another member\'s task status' do
      task = Task.create!(title: 'Status Test Task', status: 'todo', recurrence: 'none', member: member2)
      visit '/dashboard'
      # The task should not be visible on the dashboard since it's assigned to another member
      expect(page).not_to have_content('Status Test Task')
    end
  end
end
