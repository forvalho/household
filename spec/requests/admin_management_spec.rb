require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Management', type: :request do
  let(:password) { 'password123' }
  let(:admin) { Admin.create!(username: 'admin_user', password_digest: BCrypt::Password.create(password)) }

  before do
    post '/admin/login', { username: admin.username, password: password }
  end

  describe 'POST /admin/logout' do
    it 'clears the session and redirects to homepage' do
      get '/admin/logout'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('Welcome to Household!')
    end
  end

  describe 'POST /admin/admins' do
    it 'creates a new admin successfully' do
      expect {
        post '/admin/admins', { username: 'newadmin', password: 'newpass123' }
      }.to change(Admin, :count).by(1)

      expect(last_response).to be_redirect
    end

    it 'handles validation errors when creating admin' do
      post '/admin/admins', { username: admin.username, password: 'newpass123' }

      expect(last_response).to be_redirect
    end
  end

  describe 'GET /admin/admins' do
    it 'loads the admins page successfully' do
      get '/admin/admins'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Admins')
    end
  end

  describe 'GET /admin/reports' do
    it 'loads the reports page successfully' do
      # Create some data to avoid division by zero
      member = Member.create!(name: 'Test Member')
      task = Task.create!(title: 'Test Task', member: member, status: 'done', difficulty: 'silver')
      TaskCompletion.create!(task: task, member: member, completed_at: Time.now)

      get '/admin/reports'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Reports')
    end

    it 'loads reports with custom period' do
      # Create some data to avoid division by zero
      member = Member.create!(name: 'Test Member')
      task = Task.create!(title: 'Test Task', member: member, status: 'done', difficulty: 'silver')
      TaskCompletion.create!(task: task, member: member, completed_at: Time.now)

      get '/admin/reports?period=7'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Reports')
    end
  end

  describe 'POST /tasks' do
    it 'creates a new task successfully' do
      member = Member.create!(name: 'Test Member')

      expect {
        post '/tasks', {
          title: 'New Task',
          description: 'Task description',
          difficulty: 'silver',
          member_id: member.id
        }
      }.to change(Task, :count).by(1)

      expect(last_response).to be_redirect
    end

    it 'handles task creation errors' do
      expect {
        post '/tasks', { title: '' } # Invalid task
      }.not_to change(Task, :count)

      expect(last_response).to be_redirect
    end
  end
end
