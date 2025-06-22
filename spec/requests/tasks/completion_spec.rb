require 'spec_helper'

RSpec.describe 'POST /tasks/:id/complete', type: :request do
  let!(:member) { Member.create!(name: 'Test Member') }
  let!(:other_member) { Member.create!(name: 'Other Member') }
  let!(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member, status: 'todo') }

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
