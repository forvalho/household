require 'spec_helper'

# Since helpers are not loaded in the same way in tests,
# we create a dummy class to include the helper for testing.
class HelperTester
  include ApplicationHelper
  include DataHelper

  # Mock session for flash messages if needed
  def session
    @session ||= {}
  end
end

RSpec.describe DataHelper, type: :helper do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:helper) { HelperTester.new }

  describe '#outstanding_tasks' do
    it 'returns count of todo and in_progress tasks' do
      Task.create!(title: 'Todo Task', member: member, status: 'todo', difficulty: 'bronze')
      Task.create!(title: 'In Progress Task', member: member, status: 'in_progress', difficulty: 'bronze')
      Task.create!(title: 'Done Task', member: member, status: 'done', difficulty: 'bronze')

      expect(helper.outstanding_tasks(member)).to eq(2)
    end
  end

  describe '#calculate_member_points' do
    it 'calculates total points from completed tasks' do
      bronze_task = Task.create!(title: 'Bronze Task', member: member, status: 'done', difficulty: 'bronze')
      silver_task = Task.create!(title: 'Silver Task', member: member, status: 'done', difficulty: 'silver')
      gold_task = Task.create!(title: 'Gold Task', member: member, status: 'done', difficulty: 'gold')

      TaskCompletion.create!(task: bronze_task, member: member, completed_at: 1.day.ago)
      TaskCompletion.create!(task: silver_task, member: member, completed_at: 2.days.ago)
      TaskCompletion.create!(task: gold_task, member: member, completed_at: 3.days.ago)

      expect(helper.calculate_member_points(member)).to eq(9) # 1 + 3 + 5
    end

    it 'only counts completions within the specified period' do
      task = Task.create!(title: 'Old Task', member: member, status: 'done', difficulty: 'bronze')
      TaskCompletion.create!(task: task, member: member, completed_at: 40.days.ago)

      expect(helper.calculate_member_points(member, 30.days.ago)).to eq(0)
    end
  end

  describe '#calculate_member_medals' do
    it 'counts medals by difficulty' do
      bronze_task = Task.create!(title: 'Bronze Task', member: member, status: 'done', difficulty: 'bronze')
      silver_task = Task.create!(title: 'Silver Task', member: member, status: 'done', difficulty: 'silver')
      gold_task = Task.create!(title: 'Gold Task', member: member, status: 'done', difficulty: 'gold')

      TaskCompletion.create!(task: bronze_task, member: member, completed_at: 1.day.ago)
      TaskCompletion.create!(task: silver_task, member: member, completed_at: 2.days.ago)
      TaskCompletion.create!(task: gold_task, member: member, completed_at: 3.days.ago)

      medals = helper.calculate_member_medals(member)
      expect(medals[:bronze]).to eq(1)
      expect(medals[:silver]).to eq(1)
      expect(medals[:gold]).to eq(1)
    end
  end

  describe '#calculate_member_skips' do
    it 'counts skips within the specified period' do
      task = Task.create!(title: 'Skipped Task', member: member, status: 'skipped', difficulty: 'bronze')
      TaskSkip.create!(task: task, member: member, skipped_at: 1.day.ago, reason: 'Too busy')

      expect(helper.calculate_member_skips(member)).to eq(1)
    end

    it 'only counts skips within the specified period' do
      task = Task.create!(title: 'Old Skipped Task', member: member, status: 'skipped', difficulty: 'bronze')
      TaskSkip.create!(task: task, member: member, skipped_at: 40.days.ago, reason: 'Too busy')

      expect(helper.calculate_member_skips(member, 30.days.ago)).to eq(0)
    end
  end

  describe '#calculate_completion_rate' do
    it 'calculates completion rate for one-time tasks' do
      Task.create!(title: 'Completed Task', member: member, status: 'done', difficulty: 'bronze')
      Task.create!(title: 'Todo Task', member: member, status: 'todo', difficulty: 'bronze')
      Task.create!(title: 'Skipped Task', member: member, status: 'skipped', difficulty: 'bronze')

      period = 30.days.ago..Time.now
      expect(helper.calculate_completion_rate(member, period)).to eq(33.3)
    end

    it 'returns 0 for members with no tasks' do
      period = 30.days.ago..Time.now
      expect(helper.calculate_completion_rate(member, period)).to eq(0.0)
    end
  end

  describe '#find_member_or_halt' do
    it 'returns member if found' do
      found_member = helper.find_member_or_halt(member.id)
      expect(found_member).to eq(member)
    end

    # Note: halt method is not available in test context, so we skip the error test
    # In a real Sinatra context, this would raise Sinatra::NotFound
  end
end
