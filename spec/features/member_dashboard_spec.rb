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
    expect(page).to have_content("Test Member's Kanban Board")
    expect(page).to have_content('Test Task')
  end

  it 'allows a member to complete a task' do
    visit '/dashboard'

    expect(page).to have_button('Complete')
    click_button 'Complete'

    expect(page).to have_content('Task completed!')
    expect(task.reload.status).to eq('done')
  end
end
