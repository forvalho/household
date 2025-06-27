require 'spec_helper'
require 'bcrypt'

RSpec.describe 'Session-dependent helpers', type: :request do
  it 'admin_logged_in? correctly identifies an admin' do
    Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('password'))

    post '/admin/login', { username: 'admin', password: 'password' }
    expect(last_response).to be_redirect
    follow_redirect!

    # Now we should be able to access admin_logged_in? in the context
    expect(last_response.body).to include('Tasks')
  end

  it 'member_selected? correctly identifies a selected member' do
    member = Member.create!(name: 'Test Member')

    get "/members/#{member.id}/select"
    expect(last_response).to be_redirect
    follow_redirect!

    # Now we should be able to access member_selected? in the context
    expect(last_response.body).to include('Test Member')
  end
end
