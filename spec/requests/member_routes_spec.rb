require 'spec_helper'

RSpec.describe 'Member Routes', type: :request do
  let!(:member) { Member.create!(name: 'Test Member') }

  describe 'GET /members/:id/select' do
    it 'sets the session and redirects to dashboard' do
      get "/members/#{member.id}/select"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
    end
  end

  describe 'GET /dashboard' do
    it 'redirects to root if not logged in' do
      get '/dashboard'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/')
    end

    it 'shows dashboard if logged in' do
      get "/members/#{member.id}/select"
      get '/dashboard'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Tasks')
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
      post '/profile', { name: 'New Name', avatar_url: 'http://example.com/avatar.png' }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(Member.find(member.id).name).to eq('New Name')
    end

    it 'renders edit_profile on error' do
      get "/members/#{member.id}/select"
      post '/profile', { name: '' } # Invalid name
      expect(last_response.body).to include('Edit Your Profile')
    end
  end
end
