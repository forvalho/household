require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Session-dependent helpers', type: :request do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('admin123')) }

  describe 'member_selected?' do
    it 'correctly identifies a selected member' do
      get "/members/#{member.id}/select"
      expect(last_response).to be_redirect
      follow_redirect!

      # Now we should be able to access member_selected? in the context
      expect(last_response.body).to include('Test Member')
    end
  end

  xit 'admin_logged_in? correctly identifies an admin' do
    post '/admin/login', { username: 'admin', password: 'admin123' }
    expect(last_response).to be_redirect
    follow_redirect!

    # Now we should be able to access admin_logged_in? in the context
    expect(last_response.body).to include('Admin Dashboard')
  end
end
