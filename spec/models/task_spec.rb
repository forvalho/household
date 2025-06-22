require 'spec_helper'

RSpec.describe Task, type: :model do
  let(:member) { Member.create!(name: 'Test Member') }

  describe 'validations' do
    it 'is valid with a title and difficulty' do
      task = Task.new(title: 'Test Task', difficulty: 'bronze', member: member)
      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = Task.new(difficulty: 'bronze', member: member)
      expect(task).not_to be_valid
    end

    it 'is invalid without a difficulty' do
      task = Task.new(title: 'Test Task', member: member)
      expect(task).not_to be_valid
    end

    it 'is invalid with a wrong difficulty' do
      task = Task.new(title: 'Test Task', difficulty: 'invalid', member: member)
      expect(task).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:member) }
    it { should have_many(:task_completions) }
  end

  describe '#points_value' do
    it 'returns 1 for bronze tasks' do
      task = Task.new(difficulty: 'bronze')
      expect(task.points_value).to eq(1)
    end

    it 'returns 3 for silver tasks' do
      task = Task.new(difficulty: 'silver')
      expect(task.points_value).to eq(3)
    end

    it 'returns 5 for gold tasks' do
      task = Task.new(difficulty: 'gold')
      expect(task.points_value).to eq(5)
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
