require 'spec_helper'

RSpec.describe 'Task Assignment', type: :feature do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }
  let!(:member) { Member.create!(name: 'Test Member') }
  let!(:unassigned_task) { Task.create!(title: 'Unassigned Task', difficulty: 'bronze') }
  let!(:assigned_task) { Task.create!(title: 'Assigned Task', difficulty: 'silver', member: member) }

  def admin_login
    visit '/admin/login'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'password'
    click_button 'Sign In'
    visit '/admin/dashboard'
  end

  def member_login
    visit "/members/#{member.id}/select"
    visit '/dashboard'
  end

  context 'as an admin' do
    before { admin_login }

    it 'can assign a task to a member' do
      within "[data-testid='task-card-#{unassigned_task.id}']" do
        find("[data-testid='assignee-dropdown-#{unassigned_task.id}'] .dropdown-toggle").click
        click_button 'Test Member'
      end
      expect(unassigned_task.reload.member).to eq(member)
    end

    it 'can unassign a task' do
      within "[data-testid='task-card-#{assigned_task.id}']" do
        find("[data-testid='assignee-dropdown-#{assigned_task.id}'] .dropdown-toggle").click
        click_button 'Unassigned'
      end
      expect(assigned_task.reload.member).to be_nil
    end
  end

  context 'as a member' do
    before do
      assigned_task.update(member: member) # Ensure assignment
      member_login
    end

    it 'can claim an unassigned task' do
      within "[data-testid='task-card-#{unassigned_task.id}']" do
        find("[data-testid='assignee-dropdown-#{unassigned_task.id}'] .dropdown-toggle").click
        click_button 'Test Member'
      end
      expect(unassigned_task.reload.member).to eq(member)
    end

    it 'can unassign themselves from a task' do
      within "[data-testid='task-card-#{assigned_task.id}']" do
        find("[data-testid='assignee-dropdown-#{assigned_task.id}'] .dropdown-toggle").click
        click_button 'Unassigned'
      end
      expect(assigned_task.reload.member).to be_nil
    end
  end
end
