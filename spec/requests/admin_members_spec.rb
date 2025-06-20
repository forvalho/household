require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Admin Member Management', type: :request do
  let(:password) { 'password123' }
  let(:admin) { Admin.create!(username: 'admin_user', password_digest: BCrypt::Password.create(password)) }

  before do
    # Simulate admin login by setting the session directly
    # This is faster and more reliable for request specs
    post '/admin/login', { username: admin.username, password: password }
  end

  # A helper to simulate being logged in as an admin
  def with_admin_session
    allow_any_instance_of(Sinatra::Application).to receive(:admin_logged_in?).and_return(true)
    allow_any_instance_of(Sinatra::Application).to receive(:current_admin).and_return(admin)
  end

  describe 'GET /admin/members' do
    it 'loads the members page successfully' do
      with_admin_session
      get '/admin/members'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Members')
    end
  end

  describe 'POST /admin/members' do
    it 'creates a new member' do
      with_admin_session
      expect {
        post '/admin/members', { name: 'Newest Member', avatar_url: 'http://example.com/avatar.png' }
      }.to change(Member, :count).by(1)

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('Member created successfully!')
    end
  end

  describe 'POST /admin/members/:id' do
    let(:member) { Member.create!(name: 'Existing Member') }

    it 'updates an existing member' do
      with_admin_session
      post "/admin/members/#{member.id}", { name: 'Updated Name', avatar_url: member.avatar_url }

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('Member updated successfully!')
      expect(member.reload.name).to eq('Updated Name')
    end
  end
end
