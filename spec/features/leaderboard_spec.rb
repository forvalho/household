require 'spec_helper'

RSpec.describe 'Leaderboard', type: :feature do
  let!(:member1) { Member.create!(name: "Alice", active: true) }
  let!(:member2) { Member.create!(name: "Bob", active: true) }
  let!(:task1) { Task.create!(title: "Task 1", member: member1, status: 'done', points: 3, difficulty: 'bronze') }
  let!(:task2) { Task.create!(title: "Task 2", member: member2, status: 'done', points: 1, difficulty: 'bronze') }

  before do
    # Create task completions
    TaskCompletion.create!(task: task1, member: member1, completed_at: 1.day.ago)
    TaskCompletion.create!(task: task2, member: member2, completed_at: 2.days.ago)
  end

  xit 'displays leaderboard with member rankings' do
    visit "/leaderboard"

    expect(page).to have_content("Leaderboard")
    expect(page).to have_content("Alice")
    expect(page).to have_content("Bob")
    expect(page).to have_content("3") # Alice's points
    expect(page).to have_content("1") # Bob's points
  end

  xit 'allows switching between time periods' do
    visit "/leaderboard"

    expect(page).to have_select("period", selected: "Last 30 Days")

    select "Last 7 Days", from: "period"
    expect(page).to have_select("period", selected: "Last 7 Days")
  end

  xit 'shows performance scores' do
    visit "/leaderboard"

    expect(page).to have_content("100%") # Alice's performance
    expect(page).to have_content("100%") # Bob's performance
  end

  xit 'displays medals correctly' do
    visit "/leaderboard"

    expect(page).to have_css(".medal-gold")
    expect(page).to have_css(".medal-silver")
    expect(page).to have_css(".medal-bronze")
  end

  xit 'allows clicking on a member row to navigate to their dashboard' do
    visit "/leaderboard"

    click_on "Alice"

    expect(page).to have_content("Alice's Tasks")
  end

  xit 'allows clicking on another member row to navigate to their dashboard' do
    visit "/leaderboard"

    click_on "Bob"

    expect(page).to have_content("Bob's Tasks")
  end

  xit 'shows task templates in the member dashboard after clicking leaderboard row' do
    template = TaskTemplate.create!(title: "Test Template", category: "Kitchen", difficulty: "bronze")

    visit "/leaderboard"
    click_on "Alice"

    within '#templates-column' do
      expect(page).to have_content('Test Template')
      expect(page).to have_content('Kitchen')
    end
  end
end
