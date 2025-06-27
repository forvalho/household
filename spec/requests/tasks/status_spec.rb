require 'spec_helper'

RSpec.describe 'PUT /tasks/:id/status', type: :request do
  let(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let(:member) { Member.create!(name: 'Test Member') }
  let(:other_member) { Member.create!(name: 'Other Member') }
  let(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member, status: 'todo') }

  before do
    admin # Instantiate the admin
    member # Instantiate the member
    other_member # Instantiate the other member
    task # Instantiate the task
  end

  context 'denies permission for non-admin/non-assigned member (HTML)' do
    it 'redirects' do
      put "/tasks/#{task.id}/status", { status: 'in_progress' }
      expect(last_response).to be_redirect
    end
  end

  it 'denies permission for non-admin/non-assigned member (JSON) when not logged in' do
    put "/tasks/#{task.id}/status", { status: 'done' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(403)
    expect(last_response.content_type).to include('application/json')
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
