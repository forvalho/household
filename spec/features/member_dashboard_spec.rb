require 'spec_helper'

RSpec.describe 'Member Dashboard', type: :feature do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:kitchen_category) { Category.find_or_create_by!(name: 'Kitchen') }

  before do
    TaskTemplate.create!(
      title: 'Test Template',
      difficulty: 'silver',
      category: kitchen_category
    )
  end

  xit 'displays the member dashboard' do
    visit "/members/#{member.id}/select"
    expect(page).to have_content('Member Dashboard')
    expect(page).to have_content('Test Template')
  end

  xit 'shows the member their assigned tasks' do
    task = Task.create!(title: 'Assigned Task', member: member, difficulty: 'bronze', status: 'todo')

    visit "/members/#{member.id}/select"
    expect(page).to have_content('Assigned Task')
  end

  xit 'allows a member to complete a task' do
    task = Task.create!(title: 'Complete Me', member: member, difficulty: 'bronze', status: 'todo')

    visit "/members/#{member.id}/select"

    within "[data-testid='task-card-#{task.id}']" do
      find("[data-testid='action-dropdown-#{task.id}'] .dropdown-toggle").click
      click_button 'Done'
    end

    expect(page).to have_content('Task completed successfully!')
    expect(task.reload.status).to eq('done')
  end

  xit 'shows available task templates' do
    visit "/members/#{member.id}/select"
    expect(page).to have_content('Available Task Templates')
    expect(page).to have_content('Test Template')
  end

  xit 'allows a member to assign a task template to themselves' do
    visit "/members/#{member.id}/select"

    within '.task-templates' do
      click_button 'Assign to Me'
    end

    expect(page).to have_content('Task assigned successfully!')
    expect(Task.where(member: member, title: 'Test Template')).to exist
  end
end
