require 'spec_helper'

RSpec.describe ApplicationHelper do
  include ApplicationHelper

  # Mock session for testing
  def session
    @session ||= {}
  end

  describe '#format_date' do
    it 'formats a date correctly' do
      date = Date.new(2023, 12, 25)
      expect(format_date(date)).to eq('Dec 25, 2023')
    end
  end

  describe '#completed_today' do
    let(:member) { Member.create!(name: 'Test Member') }

    it 'returns 0 when no completions today' do
      expect(completed_today(member)).to eq(0)
    end

    it 'returns count of completions today' do
      task = Task.create!(title: 'Test Task', member: member)
      TaskCompletion.create!(task: task, member: member, completed_at: Time.now)

      expect(completed_today(member)).to eq(1)
    end
  end

  describe '#skipped_today' do
    let(:member) { Member.create!(name: 'Test Member') }

    it 'returns 0 when no skips today' do
      expect(skipped_today(member)).to eq(0)
    end

    it 'returns count of skips today' do
      task = Task.create!(title: 'Test Task', member: member)
      TaskSkip.create!(task: task, member: member, skipped_at: Time.now, reason: 'Too busy')

      expect(skipped_today(member)).to eq(1)
    end
  end

  describe '#total_points_today' do
    let(:member) { Member.create!(name: 'Test Member') }

    it 'returns 0 when no completions today' do
      expect(total_points_today(member)).to eq(0)
    end

    it 'returns total points from completions today' do
      task1 = Task.create!(title: 'Easy Task', member: member, points: 1)
      task2 = Task.create!(title: 'Hard Task', member: member, points: 3)

      TaskCompletion.create!(task: task1, member: member, completed_at: Time.now)
      TaskCompletion.create!(task: task2, member: member, completed_at: Time.now)

      expect(total_points_today(member)).to eq(4)
    end
  end

  describe 'flash message helpers' do
    it 'sets and gets flash messages' do
      set_flash('success', 'Test message')
      flash = get_flash

      expect(flash[:type]).to eq('success')
      expect(flash[:message]).to eq('Test message')
    end

    it 'clears flash after getting' do
      set_flash('error', 'Test error')
      get_flash
      expect(get_flash).to be_nil
    end
  end

  describe 'authentication helpers' do
    let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }
    let(:member) { Member.create!(name: 'Test Member') }

    it 'checks admin login status' do
      expect(admin_logged_in?).to be false

      session[:admin_id] = admin.id
      expect(admin_logged_in?).to be true
    end

    it 'gets current admin' do
      session[:admin_id] = admin.id
      expect(current_admin).to eq(admin)
    end

    it 'checks member selection status' do
      expect(member_selected?).to be false

      session[:member_id] = member.id
      expect(member_selected?).to be true
    end

    it 'gets current member' do
      session[:member_id] = member.id
      expect(current_member).to eq(member)
    end
  end
end
