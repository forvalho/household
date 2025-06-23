require 'spec_helper'

RSpec.describe Task, type: :model do
  let(:member) { Member.create!(name: 'Test Member') }
  let(:general_category) { Category.find_or_create_by!(name: 'General') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      task = Task.new(
        title: 'Test Task',
        member: member,
        difficulty: 'bronze',
        status: 'todo'
      )
      expect(task).to be_valid
    end

    it 'requires a title' do
      task = Task.new(member: member, difficulty: 'bronze', status: 'todo')
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'requires a member' do
      task = Task.new(title: 'Test Task', difficulty: 'bronze', status: 'todo')
      expect(task).not_to be_valid
      expect(task.errors[:member]).to include("can't be blank")
    end

    it 'validates difficulty inclusion' do
      task = Task.new(
        title: 'Test Task',
        member: member,
        difficulty: 'invalid',
        status: 'todo'
      )
      expect(task).not_to be_valid
      expect(task.errors[:difficulty]).to include('is not included in the list')
    end

    it 'validates status inclusion' do
      task = Task.new(
        title: 'Test Task',
        member: member,
        difficulty: 'bronze',
        status: 'invalid'
      )
      expect(task).not_to be_valid
      expect(task.errors[:status]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it { should belong_to(:member) }
    it { should have_many(:task_completions) }
  end

  describe '#points_value' do
    it 'returns correct points for bronze difficulty' do
      task = Task.create!(title: 'Bronze Task', member: member, difficulty: 'bronze')
      expect(task.points_value).to eq(1)
    end

    it 'returns correct points for silver difficulty' do
      task = Task.create!(title: 'Silver Task', member: member, difficulty: 'silver')
      expect(task.points_value).to eq(3)
    end

    it 'returns correct points for gold difficulty' do
      task = Task.create!(title: 'Gold Task', member: member, difficulty: 'gold')
      expect(task.points_value).to eq(5)
    end
  end

  describe '#custom_task?' do
    it 'returns true when task_template_id is nil' do
      task = Task.create!(title: 'Custom Task', member: member, difficulty: 'bronze')
      expect(task.custom_task?).to be true
    end

    it 'returns false when task_template_id is set' do
      template = TaskTemplate.create!(title: 'Test Template', difficulty: 'bronze', category: general_category)
      task = Task.create!(title: 'Template Task', member: member, difficulty: 'bronze', task_template: template)
      expect(task.custom_task?).to be false
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
