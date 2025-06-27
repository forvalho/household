require 'spec_helper'

RSpec.describe 'Percy Visual Tests', type: :feature, js: true do
  let(:member1) { Member.create!(name: 'Alice', active: true, avatar_url: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alice') }
  let(:member2) { Member.create!(name: 'Bob', active: true, avatar_url: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Bob') }
  let(:kitchen_category) { Category.create!(name: 'Kitchen', color: '#ff6b6b', icon: '🍽️') }
  let(:cleaning_category) { Category.create!(name: 'Cleaning', color: '#4ecdc4', icon: '🧹') }

  before do
    # Create some task templates
    TaskTemplate.create!(
      title: 'Empty Dishwasher',
      difficulty: 'bronze',
      category: kitchen_category
    )

    TaskTemplate.create!(
      title: 'Vacuum Living Room',
      difficulty: 'silver',
      category: cleaning_category
    )

    # Create some tasks for Alice
    Task.create!(
      title: 'Wash Dishes',
      member: member1,
      difficulty: 'bronze',
      status: 'todo',
      category: kitchen_category
    )

    Task.create!(
      title: 'Make Bed',
      member: member1,
      difficulty: 'bronze',
      status: 'done',
      category: cleaning_category
    )

    Task.create!(
      title: 'Cook Dinner',
      member: member1,
      difficulty: 'gold',
      status: 'in_progress',
      category: kitchen_category
    )
  end

  it 'captures homepage with active members' do
    # Ensure members are created
    member1 # Instantiate the member1
    member2 # Instantiate the member2

    visit '/'

    # Wait for page to load completely
    expect(page).to have_content('Household')
    expect(page).to have_content('Alice')
    # Note: Bob might not show if there are no tasks, but Alice should be there

    # Take Percy snapshot
    page.percy_snapshot('Homepage with active members')
  end

  it 'captures member dashboard with tasks' do
    visit "/members/#{member1.id}/select"

    # Wait for dashboard to load
    expect(page).to have_content("Alice's Tasks")
    expect(page).to have_content('Wash Dishes')
    expect(page).to have_content('Make Bed')
    expect(page).to have_content('Cook Dinner')

    # Wait a moment for any animations to complete
    sleep(1)

    # Take Percy snapshot
    page.percy_snapshot('Member dashboard with tasks')
  end
end
