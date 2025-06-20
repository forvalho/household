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
  let(:helper) { HelperTester.new }
  let(:member) { Member.create!(name: 'Test Member') }
  let(:start_date) { 30.days.ago.to_date }

  describe '#calculate_member_points' do
    it 'returns 0 when no completions in period' do
      expect(helper.calculate_member_points(member, start_date)).to eq(0)
    end

    it 'calculates points from completions in period' do
      task1 = Task.create!(title: 'Easy Task', member: member, points: 1)
      task2 = Task.create!(title: 'Hard Task', member: member, points: 3)

      TaskCompletion.create!(task: task1, member: member, completed_at: 15.days.ago)
      TaskCompletion.create!(task: task2, member: member, completed_at: 10.days.ago)

      expect(helper.calculate_member_points(member, start_date)).to eq(4)
    end

    it 'excludes completions outside the period' do
      task = Task.create!(title: 'Old Task', member: member, points: 2)
      TaskCompletion.create!(task: task, member: member, completed_at: 40.days.ago)

      expect(helper.calculate_member_points(member, start_date)).to eq(0)
    end
  end

  describe '#calculate_member_skips' do
    it 'returns 0 when no skips in period' do
      expect(helper.calculate_member_skips(member, start_date)).to eq(0)
    end

    it 'counts skips in period' do
      task1 = Task.create!(title: 'Task 1', member: member)
      task2 = Task.create!(title: 'Task 2', member: member)

      TaskSkip.create!(task: task1, member: member, skipped_at: 15.days.ago, reason: 'Too busy')
      TaskSkip.create!(task: task2, member: member, skipped_at: 10.days.ago, reason: 'Not feeling well')

      expect(helper.calculate_member_skips(member, start_date)).to eq(2)
    end

    it 'excludes skips outside the period' do
      task = Task.create!(title: 'Old Task', member: member)
      TaskSkip.create!(task: task, member: member, skipped_at: 40.days.ago, reason: 'Old skip')

      expect(helper.calculate_member_skips(member, start_date)).to eq(0)
    end
  end

  describe '#calculate_completion_rate' do
    it 'returns 0 if there are no tasks' do
      expect(helper.calculate_completion_rate(member, start_date)).to eq(0)
    end

    it 'returns 100 for a completed non-recurring task' do
      task = Task.create!(title: 'Test', member: member, recurrence: 'none')
      TaskCompletion.create!(member: member, task: task, completed_at: Time.now)
      expect(helper.calculate_completion_rate(member, start_date)).to eq(100.0)
    end

    it 'returns 0 for an incomplete non-recurring task' do
      Task.create!(title: 'Test', member: member, recurrence: 'none')
      expect(helper.calculate_completion_rate(member, start_date)).to eq(0.0)
    end

    it 'calculates daily task rates correctly' do
      # Task was active for all 30 days. Expected completions = 30.
      task = Task.create!(title: 'Test', member: member, recurrence: 'daily', created_at: 31.days.ago)
      # Member completed it 15 times.
      15.times { |i| TaskCompletion.create!(member: member, task: task, completed_at: i.days.ago) }
      # Expected rate: (15 / 31) * 100 = ~48.4%
      expect(helper.calculate_completion_rate(member, start_date)).to be_within(2.0).of(48.4)
    end

    it 'calculates weekly task rates correctly' do
      # Task was active for ~4 weeks. Expected completions = 4 or 5 depending on start day.
      task = Task.create!(title: 'Test', member: member, recurrence: 'weekly', created_at: 31.days.ago)
      # Member completed it twice.
      TaskCompletion.create!(member: member, task: task, completed_at: 1.day.ago)
      TaskCompletion.create!(member: member, task: task, completed_at: 10.days.ago)
      # Expected rate: (2 / 5) * 100 = 40%
      # The number of weeks in a 30 day period can be 4 or 5 depending on where the cutoffs are.
      # The code calculates 5. (2/5)*100 = 40.
      expect(helper.calculate_completion_rate(member, start_date)).to be_within(2.0).of(40.0)
    end
  end
end
