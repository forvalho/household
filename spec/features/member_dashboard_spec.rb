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

  it "supports date filtering for tasks", js: true do
    # Create a member and some tasks with different dates
    member = Member.create!(name: "Test Member", avatar_url: "https://example.com/avatar.jpg")

    # Create tasks for different dates
    today_task = Task.create!(
      title: "Today's Task",
      member: member,
      status: "todo",
      difficulty: "bronze",
      updated_at: Date.today
    )

    yesterday_task = Task.create!(
      title: "Yesterday's Task",
      member: member,
      status: "done",
      difficulty: "silver",
      updated_at: Date.yesterday
    )

    # Create a task from earlier this week (not a week ago, but earlier in current week)
    earlier_this_week_task = Task.create!(
      title: "Earlier This Week Task",
      member: member,
      status: "in_progress",
      difficulty: "gold",
      updated_at: 2.days.ago
    )

    # Visit dashboard as the member
    visit "/members/#{member.id}/select"
    expect(page).to have_current_path('/dashboard')

    # Expand the filter box so the select is visible
    find('div.card-header', text: /Today|Yesterday|This week|Last week|This month|Last month|\(\d{2}\/\d{2}\/\d{4}/).click

    # Should show only today's tasks by default
    expect(page).to have_content("Today's Task")
    expect(page).not_to have_content("Yesterday's Task")
    expect(page).not_to have_content("Earlier This Week Task")

    # Filter to show yesterday's tasks
    select "Show yesterday", from: "date_filter"
    expect(page).not_to have_content("Today's Task")
    expect(page).to have_content("Yesterday's Task")
    expect(page).not_to have_content("Earlier This Week Task")

    # Filter to show this week's tasks
    select "Show this week", from: "date_filter"
    expect(page).to have_content("Today's Task")
    expect(page).to have_content("Yesterday's Task")
    expect(page).to have_content("Earlier This Week Task")

    # Clear filter to go back to today
    select "Show today", from: "date_filter"
    expect(page).to have_content("Today's Task")
    expect(page).not_to have_content("Yesterday's Task")
    expect(page).not_to have_content("Earlier This Week Task")
  end
end
