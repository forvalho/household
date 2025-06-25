require 'spec_helper'

RSpec.describe 'Task Status Management', type: :feature do
  let!(:member1) { Member.create(name: 'Member 1', avatar_url: 'https://via.placeholder.com/40') }
  let!(:task_for_member1) { Task.create(title: 'M1 Task', status: 'in_progress', member: member1, difficulty: 'bronze') }
  let!(:another_task) { Task.create(title: 'M1 Another Task', status: 'todo', member: member1, difficulty: 'bronze') }
  let!(:todo_task) { Task.create(title: 'M1 Todo Task', status: 'todo', member: member1, difficulty: 'bronze') }

  before do
    login_as(member1)
    visit '/dashboard'
  end

  context 'when changing task status' do
    it 'can change a task from in_progress to done' do
      within "[data-testid='task-card-#{task_for_member1.id}']" do
        find("[data-testid='action-dropdown-#{task_for_member1.id}'] .dropdown-toggle").click
        find("button[type='submit']", text: 'Done').click
      end
      expect(Task.find(task_for_member1.id).status).to eq('done')
    end

    it 'can change a task from todo to in_progress' do
      within "[data-testid='task-card-#{another_task.id}']" do
        find("[data-testid='action-dropdown-#{another_task.id}'] .dropdown-toggle").click
        # Debug: Check if the button exists and is visible
        button = find("button[type='submit']", text: 'In Progress')
        puts "Found button: #{button.text}"
        puts "Button visible: #{button.visible?}"
        puts "Button disabled: #{button.disabled?}"
        button.click
      end
      # Debug: Check the task status after clicking
      puts "Task status after click: #{Task.find(another_task.id).status}"
      expect(Task.find(another_task.id).status).to eq('in_progress')
    end

    it 'can change a task directly from todo to done' do
      within "[data-testid='task-card-#{todo_task.id}']" do
        find("[data-testid='action-dropdown-#{todo_task.id}'] .dropdown-toggle").click
        find("button[type='submit']", text: 'Done').click
      end
      expect(Task.find(todo_task.id).status).to eq('done')
    end
  end
end
