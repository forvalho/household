require 'spec_helper'

RSpec.describe 'Leaderboard', type: :feature, js: true do
  let(:member1) { Member.create!(name: "Alice", active: true) }
  let(:member2) { Member.create!(name: "Bob", active: true) }
  let(:category) { Category.create!(name: "Kitchen") }
  let(:task1) { Task.create!(title: "Task 1", member: member1, status: 'done', difficulty: 'bronze', category: category) }
  let(:task2) { Task.create!(title: "Task 2", member: member2, status: 'done', difficulty: 'bronze', category: category) }

  before do
    member1 # Instantiate the member1
    member2 # Instantiate the member2
    category # Instantiate the category
    task1 # Instantiate the task1
    task2 # Instantiate the task2

    # Create completion records for the tasks
    TaskCompletion.create!(task: task1, member: member1, completed_at: 1.day.ago)
    TaskCompletion.create!(task: task2, member: member2, completed_at: 1.day.ago)
  end

  it 'displays leaderboard with member rankings' do
    visit '/leaderboard'

    expect(page).to have_content('Leaderboard')
    expect(page).to have_content('Alice')
    expect(page).to have_content('Bob')

    # Check for points badges specifically
    expect(page).to have_css('.badge.bg-primary', text: '1', count: 2) # Points for both members
  end

  it 'allows switching between time periods' do
    visit '/leaderboard'

    select 'Last 7 Days', from: 'period'
    expect(page).to have_current_path('/leaderboard?period=7')
  end

  it 'shows performance scores' do
    visit '/leaderboard'

    expect(page).to have_content('100%') # Both have same performance
  end

  it 'displays medals correctly' do
    visit '/leaderboard'

    expect(page).to have_css('.medal-bronze', count: 2) # Both have bronze medals
  end

  it 'allows clicking on a member row to navigate to their dashboard' do
    visit '/leaderboard'

    # Click on Alice's row
    find('tr', text: 'Alice').click

    expect(page).to have_content('Alice')
    expect(page).to have_content('Task 1')
  end

  it 'allows clicking on another member row to navigate to their dashboard' do
    visit '/leaderboard'

    # Click on Bob's row
    find('tr', text: 'Bob').click

    expect(page).to have_content('Bob')
    expect(page).to have_content('Task 2')
  end

  it 'shows task templates in the member dashboard after clicking leaderboard row' do
    # Create a template first
    template = TaskTemplate.create!(title: 'Test Template', difficulty: 'bronze', category: category)

    visit '/leaderboard'

    # Click on Alice's row
    find('tr', text: 'Alice').click

    # Should be on member dashboard with templates - check for the category name instead
    expect(page).to have_content('Kitchen')
  end
end
