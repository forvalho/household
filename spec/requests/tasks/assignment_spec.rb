require 'spec_helper'

RSpec.describe 'PATCH /tasks/:id/assignee', type: :request do
  let!(:admin) { Admin.create!(username: 'admin', password: 'admin123') }
  let!(:member) { Member.create!(name: 'Test Member') }
  let!(:other_member) { Member.create!(name: 'Other Member') }
  let!(:task) { Task.create!(title: 'Test Task', difficulty: 'bronze', member: member, status: 'todo') }

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
