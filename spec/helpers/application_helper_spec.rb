require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:helper) { HelperTester.new }
  let(:member) { Member.create!(name: 'Test Member') }

  describe '#format_date' do
    it 'formats a date correctly' do
      date = Date.new(2023, 12, 25)
      expect(helper.format_date(date)).to eq('Dec 25, 2023')
    end
  end

  describe '#completed_today' do
    it 'returns count of completions today' do
      task = Task.create!(title: 'Test Task', member: member, status: 'done', difficulty: 'bronze')
      TaskCompletion.create!(task: task, member: member, completed_at: Time.now)

      expect(helper.completed_today(member)).to eq(1)
    end
  end

  describe '#skipped_today' do
    it 'returns count of skips today' do
      task = Task.create!(title: 'Test Task', member: member, status: 'skipped', difficulty: 'bronze')
      TaskSkip.create!(task: task, member: member, skipped_at: Time.now, reason: 'Too busy')

      expect(helper.skipped_today(member)).to eq(1)
    end
  end

  describe '#total_points_today' do
    it 'returns total points from completions today' do
      bronze_task = Task.create!(title: 'Bronze Task', member: member, status: 'done', difficulty: 'bronze')
      silver_task = Task.create!(title: 'Silver Task', member: member, status: 'done', difficulty: 'silver')

      TaskCompletion.create!(task: bronze_task, member: member, completed_at: Time.now)
      TaskCompletion.create!(task: silver_task, member: member, completed_at: Time.now)

      expect(helper.total_points_today(member)).to eq(4) # 1 + 3
    end
  end

  describe 'logged in helpers' do
    it 'correctly identifies a selected member' do
      helper.session[:member_id] = member.id
      expect(helper.member_selected?).to be true
    end

    it 'correctly identifies an admin' do
      helper.session[:admin_id] = 1
      expect(helper.admin_logged_in?).to be true
    end
  end
end
