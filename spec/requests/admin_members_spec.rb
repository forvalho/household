require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Member Management', type: :request do
  let!(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password')) }
  let!(:member) { Member.create!(name: 'Old Name', avatar_url: 'old_url') }

  before do
    post '/admin/login', { username: admin.username, password: 'password' }
    allow_any_instance_of(Sinatra::Application).to receive(:admin_logged_in?).and_return(true)
  end

  describe 'GET /admin/members' do
    it 'loads the members page successfully' do
      get '/admin/members'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Members')
      expect(last_response.body).to include('Old Name')
    end
  end

  describe 'POST /admin/members' do
    it 'creates a new member' do
      expect {
        post '/admin/members', { name: 'New Member', avatar_url: 'new_url' }
      }.to change(Member, :count).by(1)

      expect(last_response).to be_redirect
    end
  end

  describe 'POST /admin/members/:id' do
    it 'updates an existing member' do
      post "/admin/members/#{member.id}", { name: 'New Name', avatar_url: 'new_url' }

      expect(last_response).to be_redirect
    end

    it 'handles errors when updating' do
      post "/admin/members/#{member.id}", { name: '' } # Invalid name

      expect(last_response).to be_redirect
    end
  end
end
