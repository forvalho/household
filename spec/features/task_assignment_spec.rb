require 'spec_helper'

RSpec.describe 'Task Assignment', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member1) { Member.create!(name: 'Member 1') }
  let!(:member2) { Member.create!(name: 'Member 2') }
  let!(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member1, status: 'todo') }

  before do
    post '/admin/login', { username: 'admin', password: 'admin123' }
    visit '/admin/dashboard'
  end

  def member_login
    visit "/members/#{member1.id}/select"
    visit '/dashboard'
  end

  context 'as an admin' do
    xit 'can assign a task to a member' do
      find("button[data-bs-target='#collapse-#{member1.id}']").click

      within "[data-testid='task-card-#{task.id}']" do
        find("[data-testid='assignee-dropdown-#{task.id}'] .dropdown-toggle").click
        click_button 'Member 2'
      end
      expect(page).to have_content("Task assigned successfully")
      expect(task.reload.member).to eq(member2)
    end

    xit 'can unassign a task (which deletes it)' do
      find("button[data-bs-target='#collapse-#{member1.id}']").click

      within "[data-testid='task-card-#{task.id}']" do
        find("[data-testid='assignee-dropdown-#{task.id}'] .dropdown-toggle").click
        click_button 'Unassign'
      end
      expect(page).to have_content("Task removed")
      expect(Task.find_by(id: task.id)).to be_nil
    end
  end

  context 'as a member' do
    before do
      task.update(member: member1) # Ensure assignment
      member_login
    end

    xit 'can claim an unassigned task' do
      within "[data-testid='task-card-#{task.id}']" do
        find("[data-testid='assignee-dropdown-#{task.id}'] .dropdown-toggle").click
        click_button 'Member 2'
      end
      expect(task.reload.member).to eq(member2)
    end

    xit 'can unassign themselves from a task' do
      within "[data-testid='task-card-#{task.id}']" do
        find("[data-testid='assignee-dropdown-#{task.id}'] .dropdown-toggle").click
        click_button 'Unassigned'
      end
      expect(task.reload.member).to be_nil
    end
  end
end
