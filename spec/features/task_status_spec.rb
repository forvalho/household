require 'spec_helper'

RSpec.describe 'Task Status Management', type: :feature do
  let!(:member1) { Member.create(name: 'Member 1', avatar_url: 'https://via.placeholder.com/40') }
  let!(:task_for_member1) { Task.create(title: 'M1 Task', status: 'in_progress', member: member1, difficulty: 'bronze') }
  let!(:another_task) { Task.create(title: 'M1 Another Task', status: 'todo', member: member1, difficulty: 'bronze') }

  before do
    login_as(member1)
    visit '/dashboard'
  end

  context 'when changing task status' do
    it 'can change a task from in_progress to done' do
      within "[data-testid='task-card-#{task_for_member1.id}']" do
        find("[data-testid='action-dropdown-#{task_for_member1.id}'] .dropdown-toggle").click
        click_button 'Done'
      end
      expect(Task.find(task_for_member1.id).status).to eq('done')
    end

    it 'can change a task from todo to in_progress' do
      within "[data-testid='task-card-#{another_task.id}']" do
        find("[data-testid='action-dropdown-#{another_task.id}'] .dropdown-toggle").click
        click_button 'In Progress'
      end
      expect(Task.find(another_task.id).status).to eq('in_progress')
    end
  end
end
