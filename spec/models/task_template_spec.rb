require 'spec_helper'

RSpec.describe TaskTemplate, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      template = TaskTemplate.new(
        title: 'Test Template',
        difficulty: 'bronze',
        category: 'Kitchen'
      )
      expect(template).to be_valid
    end

    it 'requires a title' do
      template = TaskTemplate.new(difficulty: 'bronze', category: 'Kitchen')
      expect(template).not_to be_valid
      expect(template.errors[:title]).to include("can't be blank")
    end

    it 'requires a category' do
      template = TaskTemplate.new(title: 'Test Template', difficulty: 'bronze')
      expect(template).not_to be_valid
      expect(template.errors[:category]).to include("can't be blank")
    end

    it 'validates difficulty inclusion' do
      template = TaskTemplate.new(
        title: 'Test Template',
        difficulty: 'invalid',
        category: 'Kitchen'
      )
      expect(template).not_to be_valid
      expect(template.errors[:difficulty]).to include('is not included in the list')
    end

    it 'accepts valid difficulties' do
      %w[bronze silver gold].each do |difficulty|
        template = TaskTemplate.new(
          title: 'Test Template',
          difficulty: difficulty,
          category: 'Kitchen'
        )
        expect(template).to be_valid
      end
    end
  end

  describe '#points_value' do
    it 'returns correct points for bronze difficulty' do
      template = TaskTemplate.new(difficulty: 'bronze')
      expect(template.points_value).to eq(1)
    end

    it 'returns correct points for silver difficulty' do
      template = TaskTemplate.new(difficulty: 'silver')
      expect(template.points_value).to eq(3)
    end

    it 'returns correct points for gold difficulty' do
      template = TaskTemplate.new(difficulty: 'gold')
      expect(template.points_value).to eq(5)
    end

    it 'returns 0 for invalid difficulty' do
      template = TaskTemplate.new(difficulty: 'invalid')
      expect(template.points_value).to eq(0)
    end
  end

  describe '#medal' do
    it 'returns the difficulty as medal' do
      template = TaskTemplate.new(difficulty: 'silver')
      expect(template.medal).to eq('silver')
    end
  end

  describe '#create_task_for' do
    let(:member) { Member.create!(name: 'Test Member') }
    let(:template) do
      TaskTemplate.create!(
        title: 'Test Template',
        description: 'Test description',
        difficulty: 'silver',
        category: 'Kitchen'
      )
    end

    it 'creates a new task from the template' do
      task = template.create_task_for(member)

      expect(task).to be_persisted
      expect(task.title).to eq('Test Template')
      expect(task.description).to eq('Test description')
      expect(task.difficulty).to eq('silver')
      expect(task.category).to eq('Kitchen')
      expect(task.member).to eq(member)
      expect(task.status).to eq('todo')
    end

    it 'creates a task with correct attributes' do
      task = template.create_task_for(member)

      expect(task).to be_a(Task)
      expect(task.member_id).to eq(member.id)
      expect(task.status).to eq('todo')
    end
  end
end
