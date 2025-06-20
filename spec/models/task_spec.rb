require 'spec_helper'

RSpec.describe Task, type: :model do
  let(:member) { Member.create!(name: 'Test Member') }

  describe 'validations' do
    it 'is valid with a title and member' do
      task = Task.new(title: 'Test Task', member: member)
      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = Task.new(title: nil, member: member)
      expect(task).not_to be_valid
    end

    it 'is invalid with a bad status' do
        task = Task.new(title: 'Test', member: member, status: 'invalid_status')
        expect(task).not_to be_valid
    end

    it 'is invalid with a bad recurrence' do
      task = Task.new(title: 'Test', member_id: member.id, recurrence: 'invalid_recurrence')
      expect(task).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:member) }
    it { should have_many(:task_completions) }
    it { should have_many(:task_skips) }
  end

  describe '#points_value' do
    it 'returns 1 for easy tasks' do
      task = Task.new(difficulty: 'easy')
      expect(task.points_value).to eq(1)
    end

    it 'returns 2 for medium tasks' do
      task = Task.new(difficulty: 'medium')
      expect(task.points_value).to eq(2)
    end

    it 'returns 3 for hard tasks' do
      task = Task.new(difficulty: 'hard')
      expect(task.points_value).to eq(3)
    end
  end
end

# A simple matcher for associations
RSpec::Matchers.define :belong_to do |expected|
    match do |actual|
      association = actual.class.reflect_on_association(expected)
      association && association.macro == :belongs_to
    end
end

RSpec::Matchers.define :have_many do |expected|
    match do |actual|
      association = actual.class.reflect_on_association(expected)
      association && association.macro == :has_many
    end
end
