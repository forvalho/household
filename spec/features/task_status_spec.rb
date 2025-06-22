require 'spec_helper'

RSpec.describe 'Task Status Changes', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }
  let!(:member1) { Member.create!(name: 'Member One') }
  let!(:member2) { Member.create!(name: 'Member Two') }
  let!(:task_for_member1) { Task.create!(title: 'M1 Task', difficulty: 'bronze', member: member1, status: 'todo') }
  let!(:unassigned_task) { Task.create!(title: 'Unassigned Task', difficulty: 'silver', status: 'unassigned') }

  def admin_login
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'password'
    click_button 'Sign In'
    visit '/admin/dashboard'
  end

  def member_login(member)
    visit "/members/#{member.id}/select"
    visit '/dashboard'
  end

  context 'as an admin' do
    before { admin_login }

    it 'can change a task from todo to in_progress' do
      within "[data-testid='task-card-#{task_for_member1.id}']" do
        find("[data-testid='action-dropdown-#{task_for_member1.id}'] .dropdown-toggle").click
        click_button 'In Progress'
      end
      expect(task_for_member1.reload.status).to eq('in_progress')
    end
  end

  context 'as a member' do
    before { member_login(member1) }

    it 'can change their own task from todo to in_progress' do
      within "[data-testid='task-card-#{task_for_member1.id}']" do
        find("[data-testid='action-dropdown-#{task_for_member1.id}'] .dropdown-toggle").click
        click_button 'In Progress'
      end
      expect(task_for_member1.reload.status).to eq('in_progress')
    end

    xit 'cannot change an unassigned task' do
      within "[data-testid='task-card-#{unassigned_task.id}']" do
        find("[data-testid='action-dropdown-#{unassigned_task.id}'] .dropdown-toggle").click
        expect(page).to have_button('In Progress', disabled: true)
      end
    end

    it 'cannot see tasks assigned to other members' do
      task_for_member2 = Task.create!(title: 'M2 Task', difficulty: 'gold', member: member2, status: 'todo')
      visit '/dashboard'
      expect(page).not_to have_content('M2 Task')
    end
  end
end
