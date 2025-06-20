require 'spec_helper'

RSpec.describe 'Task Coverage', type: :request do
  let(:admin) { Admin.create!(username: 'admin', password: 'password') }
  let(:member) { Member.create!(name: 'Test Member') }
  let(:other_member) { Member.create!(name: 'Other Member') }
  let!(:task) { Task.create!(title: 'Test Task', member: member, status: 'todo', difficulty: 'bronze') }
  let!(:other_task) { Task.create!(title: 'Other member task', member: other_member, status: 'todo', difficulty: 'bronze') }
  let!(:unassigned_task) { Task.create!(title: 'Unassigned Task', status: 'unassigned', difficulty: 'bronze') }

  def login_admin
    post '/admin/login', username: admin.username, password: 'password'
  end

  def login_member(member)
    get "/members/#{member.id}/select"
  end

  describe "PUT /tasks/:id/status" do
    context "as an admin" do
      before { login_admin }
      xit "updates the status" do
        put "/tasks/#{task.id}/status", { status: 'in_progress' }
        expect(task.reload.status).to eq('in_progress')
        expect(last_request.env['rack.session']['flash']['success']).to eq('Task status updated to In Progress')
      end

      xit 'updates the status with a JSON response' do
        put "/tasks/#{task.id}/status", { status: 'in_progress' }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)['status']).to eq('in_progress')
      end
    end

    context "as a member" do
      xit "cannot update another member's task" do
        login_member(member)
        put "/tasks/#{other_task.id}/status", { status: 'in_progress' }
        expect(other_task.reload.status).to eq('todo')
        expect(last_request.env['rack.session']['flash']['error']).to eq('Permission denied')
      end
    end
  end

  describe "POST /tasks/:id/skip" do
    context "as a member" do
      before { login_member(member) }

      xit "skips their own task" do
        expect {
          post "/tasks/#{task.id}/skip", { reason: 'a reason' }
        }.to change(TaskSkip, :count).by(1)
        expect(task.reload.status).to eq('skipped')
        expect(last_request.env['rack.session']['flash']['warning']).to eq('Task skipped with reason recorded')
      end

      xit "cannot skip another member's task" do
        post "/tasks/#{other_task.id}/skip", { reason: 'a reason' }
        expect(other_task.reload.status).to eq('todo')
        expect(last_request.env['rack.session']['flash']['error']).to eq('You can only skip your own tasks')
      end
    end
  end

  describe "PATCH /tasks/:id/assignee" do
    context "as admin" do
      before { login_admin }
      it "assigns a task to a member" do
        patch "/tasks/#{unassigned_task.id}/assignee", { member_id: member.id }
        expect(unassigned_task.reload.member_id).to eq(member.id)
      end

      it "unassigns a task" do
        patch "/tasks/#{task.id}/assignee", { member_id: '' }
        expect(task.reload.member_id).to be_nil
      end
    end

    context "as member" do
      before { login_member(member) }
      it "can claim an unassigned task" do
        patch "/tasks/#{unassigned_task.id}/assignee", { member_id: member.id }
        expect(unassigned_task.reload.member_id).to eq(member.id)
      end

      it "can unassign themselves" do
        patch "/tasks/#{task.id}/assignee", { member_id: '' }
        expect(task.reload.member_id).to be_nil
      end

      it "cannot assign a task to someone else" do
        patch "/tasks/#{unassigned_task.id}/assignee", { member_id: other_member.id }
        expect(unassigned_task.reload.member_id).to be_nil
      end

      it "cannot unassign someone else" do
        patch "/tasks/#{other_task.id}/assignee", { member_id: '' }
        expect(other_task.reload.member_id).to eq(other_member.id)
      end
    end
  end

  describe "POST /tasks/:id/complete" do
    context "as a member" do
      before { login_member(member) }

      it "completes a non-recurring task" do
        expect {
          post "/tasks/#{task.id}/complete"
        }.to change(TaskCompletion, :count).by(1)
        expect(task.reload.status).to eq('done')
      end

      it "completes a daily recurring task" do
        daily_task = Task.create!(title: 'Daily Task', member: member, status: 'todo', recurrence: 'daily', due_date: Date.today, difficulty: 'bronze')
        post "/tasks/#{daily_task.id}/complete"
        expect(daily_task.reload.status).to eq('todo')
        expect(daily_task.due_date).to eq(Date.today + 1.day)
      end

      it "completes a weekly recurring task" do
        weekly_task = Task.create!(title: 'Weekly Task', member: member, status: 'todo', recurrence: 'weekly', due_date: Date.today, difficulty: 'bronze')
        post "/tasks/#{weekly_task.id}/complete"
        expect(weekly_task.reload.status).to eq('todo')
        expect(weekly_task.due_date).to be > Date.today + 6.days
      end

      it "allows a member to claim and complete an unassigned task" do
        expect {
          post "/tasks/#{unassigned_task.id}/complete"
        }.to change(TaskCompletion, :count).by(1)
        expect(unassigned_task.reload.status).to eq('done')
        expect(unassigned_task.member_id).to eq(member.id)
      end

      it "completes a daily recurring task with no initial due date" do
        daily_task = Task.create!(title: 'Daily Task', member: member, status: 'todo', recurrence: 'daily', due_date: nil, difficulty: 'bronze')
        post "/tasks/#{daily_task.id}/complete"
        expect(daily_task.reload.status).to eq('todo')
        expect(daily_task.due_date).to eq(Date.today + 1.day)
      end

      it "completes a weekly recurring task with no initial due date" do
        weekly_task = Task.create!(title: 'Weekly Task', member: member, status: 'todo', recurrence: 'weekly', due_date: nil, difficulty: 'bronze')
        post "/tasks/#{weekly_task.id}/complete"
        expect(weekly_task.reload.status).to eq('todo')
        expect(weekly_task.due_date).to be > Date.today + 6.days
      end

      xit "prevents completing another member's task" do
        post "/tasks/#{other_task.id}/complete"
        expect(other_task.reload.status).to eq('todo')
        expect(last_request.env['rack.session']['flash']['error']).to eq('You can only complete your own tasks')
      end
    end
  end
end
