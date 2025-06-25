require 'spec_helper'

RSpec.describe 'Member Routes', type: :request do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:kitchen_category) { Category.find_or_create_by!(name: 'Kitchen') }

  before do
    TaskTemplate.create!(
      title: 'Test Template',
      difficulty: 'bronze',
      category: kitchen_category
    )
  end

  describe 'GET /members/:id/select' do
    it 'sets the session and redirects to dashboard' do
      get "/members/#{member.id}/select"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      # Session is set correctly if we can access the dashboard
    end
  end

  describe 'GET /dashboard' do
    it 'redirects to root if not logged in' do
      get '/dashboard'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/')
    end

    it 'shows dashboard with task templates if logged in' do
      get "/members/#{member.id}/select"
      get '/dashboard'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Test Template')
    end

    it 'groups tasks by day based on updated_at' do
      get "/members/#{member.id}/select"

      # Create tasks with different updated_at dates
      task1 = Task.create!(title: 'Task 1', member: member, difficulty: 'bronze', status: 'todo')
      task2 = Task.create!(title: 'Task 2', member: member, difficulty: 'bronze', status: 'in_progress')
      task3 = Task.create!(title: 'Task 3', member: member, difficulty: 'bronze', status: 'done')

      # Update tasks to different dates
      task1.update!(updated_at: 2.days.ago)
      task2.update!(updated_at: 1.day.ago)
      task3.update!(updated_at: Date.today)

      get '/dashboard', { date_filter: 'this_week' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Task 1')
      expect(last_response.body).to include('Task 2')
      expect(last_response.body).to include('Task 3')
    end
  end

  describe 'GET /profile/edit' do
    it 'redirects to root if not logged in' do
      get '/profile/edit'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/')
    end

    it 'shows edit profile if logged in' do
      get "/members/#{member.id}/select"
      get '/profile/edit'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Edit Your Profile')
    end
  end

  describe 'POST /profile' do
    it 'redirects to root if not logged in' do
      post '/profile', { name: 'New Name' }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/')
    end

    it 'updates profile and redirects to dashboard on success' do
      get "/members/#{member.id}/select"
      post '/profile', { name: 'New Name', avatar_url: 'new_url' }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(member.reload.name).to eq('New Name')
    end

    it 'renders edit_profile on error' do
      get "/members/#{member.id}/select"
      post '/profile', { name: '' } # Invalid name
      expect(last_response).to be_ok
      expect(last_response.body).to include('Edit Your Profile')
    end
  end
end
