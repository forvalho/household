require 'spec_helper'

RSpec.describe 'Member Dashboard', type: :feature do
  let!(:member) { Member.create!(name: 'Test Member') }
  let!(:task) { Task.create!(title: 'Test Task', member: member, status: 'todo', recurrence: 'none') }

  before do
    # Simulate member login
    visit "/members/#{member.id}/select"
  end

  it 'displays the member dashboard' do
    expect(page).to have_content("Test Member's Tasks")
    expect(page).to have_content('Unassigned')
    expect(page).to have_content('To Do')
    expect(page).to have_content('In Progress')
    expect(page).to have_content('Done')
  end

  it 'shows the member their assigned tasks' do
    visit '/dashboard'
    expect(page).to have_content("Test Member's Tasks")
    expect(page).to have_content('Test Task')
  end

  it 'allows a member to complete a task' do
    visit '/dashboard'

    # A task must be in progress before it can be completed
    find("[data-task-id='#{task.id}'] .action-dropdown .dropdown-toggle").click
    click_button 'In Progress'

    expect(page).to have_content('Task status updated to In Progress')
    expect(task.reload.status).to eq('in_progress')

    # Now, complete the task
    find("[data-task-id='#{task.id}'] .action-dropdown .dropdown-toggle").click
    click_button 'Done'

    expect(page).to have_content('Task completed!')
    expect(task.reload.status).to eq('done')
  end
end
