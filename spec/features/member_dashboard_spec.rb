require 'spec_helper'

RSpec.describe 'Member Dashboard', type: :feature do
  let!(:member) { Member.create!(name: 'Test Member', avatar_url: 'http://example.com/avatar.png') }
  let!(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member, status: 'in_progress') }
  let!(:template) do
    TaskTemplate.create!(
      title: 'Test Template',
      difficulty: 'silver',
      category: 'Kitchen'
    )
  end

  before do
    # Simulate member selection by visiting the select page
    visit "/members/#{member.id}/select"
  end

  it 'displays the member dashboard' do
    visit '/dashboard'
    expect(page).to have_content("Test Member's Tasks")
    expect(page).to have_css("img[src*='http://example.com/avatar.png']")
  end

  it 'shows available task templates' do
    visit '/dashboard'
    within '#templates-column' do
      expect(page).to have_content('Test Template')
      expect(page).to have_content('Kitchen')
      expect(page).to have_button('Assign to Me')
    end
  end

  it 'shows the member their assigned tasks' do
    visit '/dashboard'
    within '#in-progress-column' do
      expect(page).to have_content('Test Task')
    end
  end

  xit 'allows a member to assign a task template to themselves' do
    visit '/dashboard'

    # Click the "Assign to Me" button on the specific template
    within '#templates-column' do
      within '.task-card', text: 'Test Template' do
        click_button 'Assign to Me'
      end
    end

    # Should redirect to dashboard and show success message
    expect(page).to have_content("Task 'Test Template' assigned to you!")

    # The task should now appear in the "To Do" column
    within '#todo-column' do
      expect(page).to have_content('Test Template')
    end
  end

  it 'allows a member to complete a task' do
    visit '/dashboard'

    # Find the task card and click the complete button
    within "[data-testid='task-card-#{task.id}']" do
      find("[data-testid='action-dropdown-#{task.id}'] .dropdown-toggle").click
      click_button 'Done'
    end

    # Check that the task is now in the "Done" column
    within '#done-column' do
      expect(page).to have_content('Test Task')
    end
  end
end
