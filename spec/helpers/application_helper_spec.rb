require 'spec_helper'

# Helper tester for application helper tests
class HelperTester
  include ApplicationHelper
  include AdminHelper

  # Mock session for flash messages if needed
  def session
    @session ||= {}
  end
end

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

  describe 'avatar style helpers' do
    before do
      # Clean up members
      Member.destroy_all
    end

    it 'returns all dicebear styles' do
      expect(helper.all_dicebear_styles).to include('adventurer', 'avataaars', 'shapes', 'pixel-art')
    end

    it 'returns the default enabled avatar styles' do
      expect(helper.default_enabled_avatar_styles).to include('adventurer', 'avataaars', 'shapes')
    end

    it 'returns enabled avatar styles from settings if set' do
      allow(Setting).to receive(:get).with('enabled_avatar_styles').and_return(["adventurer", "shapes"].to_json)
      expect(helper.enabled_avatar_styles).to eq(["adventurer", "shapes"])
    end

    it 'returns default enabled avatar styles if settings is not set' do
      allow(Setting).to receive(:get).with('enabled_avatar_styles').and_return(nil)
      expect(helper.enabled_avatar_styles).to eq(helper.default_enabled_avatar_styles)
    end

    it 'counts avatar styles in use by members' do
      Member.create!(name: 'A', avatar_url: 'https://api.dicebear.com/8.x/adventurer/svg?seed=foo')
      Member.create!(name: 'B', avatar_url: 'https://api.dicebear.com/8.x/shapes/svg?seed=bar')
      counts = helper.avatar_style_in_use_counts
      expect(counts['adventurer']).to eq(1)
      expect(counts['shapes']).to eq(1)
    end
  end
end
