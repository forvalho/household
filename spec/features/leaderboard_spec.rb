require 'spec_helper'

RSpec.describe 'Leaderboard', type: :feature do
  let!(:member1) { Member.create!(name: 'Alice', avatar_url: 'http://example.com/alice.png') }
  let!(:member2) { Member.create!(name: 'Bob', avatar_url: 'http://example.com/bob.png') }
  let!(:template) do
    TaskTemplate.create!(
      title: 'Test Template',
      difficulty: 'bronze',
      category: 'Kitchen'
    )
  end

  before do
    # Create some task completions to generate points
    task1 = Task.create!(title: 'Task 1', difficulty: 'bronze', member: member1, status: 'done')
    task2 = Task.create!(title: 'Task 2', difficulty: 'silver', member: member2, status: 'done')

    TaskCompletion.create!(task: task1, member: member1, completed_at: 1.day.ago)
    TaskCompletion.create!(task: task2, member: member2, completed_at: 1.day.ago)
  end

  it 'displays the leaderboard with member rankings' do
    visit '/leaderboard'

    expect(page).to have_content('Leaderboard')
    expect(page).to have_content('Alice')
    expect(page).to have_content('Bob')
    expect(page).to have_content('Points')
    expect(page).to have_content('Medals')
  end

  it 'shows clickable rows for each member' do
    visit '/leaderboard'

    # Check that rows have the clickable class
    expect(page).to have_css('tr.clickable-row')

    # Check that cursor changes on hover (this is tested via CSS)
    expect(page).to have_css('tr[style*="cursor: pointer"]')
  end

  it 'allows clicking on a member row to navigate to their dashboard' do
    visit '/leaderboard'

    # Click on Alice's row
    find('tr.clickable-row', text: 'Alice').click

    # Should redirect to Alice's dashboard
    expect(page).to have_content("Alice's Tasks")
    expect(page).to have_content('Available Tasks')
  end

  it 'allows clicking on another member row to navigate to their dashboard' do
    visit '/leaderboard'

    # Click on Bob's row
    find('tr.clickable-row', text: 'Bob').click

    # Should redirect to Bob's dashboard
    expect(page).to have_content("Bob's Tasks")
    expect(page).to have_content('Available Tasks')
  end

  it 'shows task templates in the member dashboard after clicking leaderboard row' do
    visit '/leaderboard'

    # Click on Alice's row
    find('tr.clickable-row', text: 'Alice').click

    # Should see task templates in the dashboard
    within '#templates-column' do
      expect(page).to have_content('Test Template')
      expect(page).to have_content('Kitchen')
    end
  end

  it 'allows filtering by time period' do
    visit '/leaderboard'

    # Check that the period selector is present
    expect(page).to have_select('period')

    # Change to 7 days
    select 'Last 7 Days', from: 'period'
    # The form should auto-submit, but we need to check the URL
    expect(page).to have_current_path('/leaderboard')
    expect(page).to have_select('period', selected: 'Last 7 Days')
  end
end
