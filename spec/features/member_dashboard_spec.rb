require 'spec_helper'

RSpec.describe 'Member Dashboard', type: :feature do
  let(:member) { Member.create!(name: 'Test Member') }
  let!(:task) { Task.create!(title: 'Test Task', member: member, status: 'todo') }

  before do
    # Simulate member login
    visit "/members/#{member.id}/select"
  end

  it 'shows the member their assigned tasks' do
    visit '/dashboard'
    expect(page).to have_content('Welcome, Test Member!')
    expect(page).to have_content('Test Task')
  end

  it 'allows a member to complete a task' do
    visit '/dashboard'

    # This might need adjustment depending on your final UI for task completion
    # For now, we assume a button exists
    click_button 'Complete'

    expect(page).to have_content('Task completed!')
    expect(task.reload.status).to eq('done')
  end
end
