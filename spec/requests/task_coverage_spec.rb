require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Task Coverage', type: :request do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('admin123')) }

  before do
    post '/admin/login', { username: 'admin', password: 'admin123' }
    follow_redirect!
  end

  describe 'GET /admin/reports' do
    it 'displays member completion rates' do
      # Create some tasks for the member
      Task.create!(title: 'Completed Task', member: member, status: 'done', difficulty: 'bronze')
      Task.create!(title: 'Todo Task', member: member, status: 'todo', difficulty: 'bronze')
      Task.create!(title: 'Skipped Task', member: member, status: 'skipped', difficulty: 'bronze')

      get '/admin/reports'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Test Member')
      expect(last_response.body).to include('33.3%') # 1 out of 3 tasks completed
    end

    it 'handles members with no tasks' do
      get '/admin/reports'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Test Member')
      expect(last_response.body).to include('0.0%')
    end

    it 'displays points and medals' do
      bronze_task = Task.create!(title: 'Bronze Task', member: member, status: 'done', difficulty: 'bronze')
      silver_task = Task.create!(title: 'Silver Task', member: member, status: 'done', difficulty: 'silver')
      gold_task = Task.create!(title: 'Gold Task', member: member, status: 'done', difficulty: 'gold')

      TaskCompletion.create!(task: bronze_task, member: member, completed_at: 1.day.ago)
      TaskCompletion.create!(task: silver_task, member: member, completed_at: 2.days.ago)
      TaskCompletion.create!(task: gold_task, member: member, completed_at: 3.days.ago)

      get '/admin/reports'
      expect(last_response).to be_ok
      expect(last_response.body).to include('9') # Total points
      expect(last_response.body).to include('1') # Gold medals
      expect(last_response.body).to include('1') # Silver medals
      expect(last_response.body).to include('1') # Bronze medals
    end

    it 'displays skip count' do
      task = Task.create!(title: 'Skipped Task', member: member, status: 'skipped', difficulty: 'bronze')
      TaskSkip.create!(task: task, member: member, skipped_at: 1.day.ago, reason: 'Too busy')

      get '/admin/reports'
      expect(last_response).to be_ok
      expect(last_response.body).to include('1') # Skip count
    end

    it 'filters by date range' do
      # Create tasks with different completion dates
      old_task = Task.create!(title: 'Old Task', member: member, status: 'done', difficulty: 'bronze')
      recent_task = Task.create!(title: 'Recent Task', member: member, status: 'done', difficulty: 'bronze')

      TaskCompletion.create!(task: old_task, member: member, completed_at: 40.days.ago)
      TaskCompletion.create!(task: recent_task, member: member, completed_at: 1.day.ago)

      get '/admin/reports?start_date=30&end_date=1'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Recent Task')
      expect(last_response.body).not_to include('Old Task')
    end
  end

  describe 'GET /leaderboard' do
    it 'displays leaderboard with points' do
      member2 = Member.create!(name: 'Another Member')

      # Member 1: 3 points
      bronze_task = Task.create!(title: 'Bronze Task', member: member, status: 'done', difficulty: 'bronze')
      TaskCompletion.create!(task: bronze_task, member: member, completed_at: 1.day.ago)

      # Member 2: 5 points
      gold_task = Task.create!(title: 'Gold Task', member: member2, status: 'done', difficulty: 'gold')
      TaskCompletion.create!(task: gold_task, member: member2, completed_at: 1.day.ago)

      get '/leaderboard'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Another Member')
      expect(last_response.body).to include('Test Member')
      # Member 2 should appear first (more points)
      expect(last_response.body.index('Another Member')).to be < last_response.body.index('Test Member')
    end

    it 'handles members with no points' do
      get '/leaderboard'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Test Member')
      expect(last_response.body).to include('0')
    end
  end
end
