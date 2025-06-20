require 'spec_helper'

RSpec.describe 'Task Recurrence', type: :request do
  let(:member) { Member.create!(name: 'Test Member') }

  before do
    # Simulate member login by setting the session
    post "/members/#{member.id}/select"
    allow_any_instance_of(Sinatra::Application).to receive(:member_selected?).and_return(true)
    allow_any_instance_of(Sinatra::Application).to receive(:current_member).and_return(member)
  end

  context 'when completing a daily task' do
    let(:task) { Task.create!(title: 'Daily Task', recurrence: 'daily', due_date: Date.today) }

    it 'advances the due date by one day' do
      post "/tasks/#{task.id}/complete"
      expect(task.reload.due_date).to eq(Date.today + 1.day)
      expect(task.reload.status).to eq('todo')
    end
  end

  context 'when completing a weekly task' do
    let(:task) { Task.create!(title: 'Weekly Task', recurrence: 'weekly', due_date: Date.today) }

    it 'advances the due date by one week' do
      post "/tasks/#{task.id}/complete"
      expect(task.reload.due_date).to eq(Date.today + 1.week)
      expect(task.reload.status).to eq('todo')
    end
  end

  context 'when completing a non-recurring task' do
    let(:task) { Task.create!(title: 'One-time Task', recurrence: 'none') }

    it 'sets the status to done' do
      post "/tasks/#{task.id}/complete"
      expect(task.reload.status).to eq('done')
    end
  end
end
