require 'spec_helper'

RSpec.describe 'Task Routes', type: :request do
  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member) { Member.create!(name: 'Test Member') }
  let!(:other_member) { Member.create!(name: 'Other Member') }
  let!(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member, status: 'todo') }

  describe 'PUT /tasks/:id/status' do
    it 'denies permission for non-admin/non-assigned member (HTML)' do
      put "/tasks/#{task.id}/status", { status: 'done' }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
    end

    xit 'PUT /tasks/:id/status denies permission for non-admin/non-assigned member (JSON) when not logged in' do
      put "/tasks/#{task.id}/status", { status: 'done' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(302)
      expect(last_response.content_type).to include('text/html')
    end

    it 'denies permission for non-admin/non-assigned member (JSON) when logged in as other member' do
      get "/members/#{other_member.id}/select"
      put "/tasks/#{task.id}/status", { status: 'done' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(403)
      expect(last_response.content_type).to include('application/json')
    end

    it 'updates status for admin (HTML)' do
      post '/admin/login', { username: admin.username, password: 'admin123' }
      put "/tasks/#{task.id}/status", { status: 'done' }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(task.reload.status).to eq('done')
    end

    it 'updates status for admin (JSON)' do
      post '/admin/login', { username: admin.username, password: 'admin123' }
      put "/tasks/#{task.id}/status", { status: 'done' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('application/json')
    end
  end

  describe 'POST /tasks/:id/complete' do
    it 'redirects if not logged in as member' do
      post "/tasks/#{task.id}/complete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/')
    end

    it 'allows assigned member to complete task' do
      get "/members/#{member.id}/select"
      post "/tasks/#{task.id}/complete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(task.reload.status).to eq('done')
    end

    it 'denies other member from completing task' do
      get "/members/#{other_member.id}/select"
      post "/tasks/#{task.id}/complete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(task.reload.status).not_to eq('done')
    end
  end

  describe 'PATCH /tasks/:id/assignee' do
    it 'redirects if not logged in as admin or member' do
      patch "/tasks/#{task.id}/assignee", { member_id: '' }
      expect(last_response).to be_redirect
    end

    it 'denies member from assigning task they do not own' do
      get "/members/#{other_member.id}/select"
      patch "/tasks/#{task.id}/assignee", { member_id: other_member.id }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/dashboard')
      expect(task.reload.member_id).to eq(member.id)
    end

    it 'just redirects if assignment does not change' do
      post '/admin/login', { username: admin.username, password: 'admin123' }
      patch "/tasks/#{task.id}/assignee", { member_id: member.id }
      expect(last_response).to be_redirect
    end
  end
end
