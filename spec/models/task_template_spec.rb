require 'spec_helper'

RSpec.describe TaskTemplate, type: :model do
  let(:kitchen_category) { Category.find_or_create_by!(name: 'Kitchen') }
  let(:general_category) { Category.find_or_create_by!(name: 'General') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      template = TaskTemplate.new(
        title: 'Test Template',
        difficulty: 'bronze',
        category: kitchen_category
      )
      expect(template).to be_valid
    end

    it 'requires a title' do
      template = TaskTemplate.new(difficulty: 'bronze', category: kitchen_category)
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
        category: kitchen_category
      )
      expect(template).not_to be_valid
      expect(template.errors[:difficulty]).to include('is not included in the list')
    end

    it 'accepts valid difficulties' do
      ['bronze', 'silver', 'gold'].each do |difficulty|
        template = TaskTemplate.new(
          title: 'Test Template',
          difficulty: difficulty,
          category: kitchen_category
        )
        expect(template).to be_valid
      end
    end
  end

  describe '#points_value' do
    it 'returns correct points for bronze difficulty' do
      template = TaskTemplate.create!(
        title: 'Bronze Task',
        difficulty: 'bronze',
        category: kitchen_category
      )
      expect(template.points_value).to eq(1)
    end

    it 'returns correct points for silver difficulty' do
      template = TaskTemplate.create!(
        title: 'Silver Task',
        difficulty: 'silver',
        category: kitchen_category
      )
      expect(template.points_value).to eq(3)
    end

    it 'returns correct points for gold difficulty' do
      template = TaskTemplate.create!(
        title: 'Gold Task',
        difficulty: 'gold',
        category: kitchen_category
      )
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

  describe '#generic_task?' do
    it 'returns true for Generic Task' do
      template = TaskTemplate.new(title: 'Generic Task')
      expect(template.generic_task?).to be true
    end

    it 'returns false for other tasks' do
      template = TaskTemplate.new(title: 'Regular Task')
      expect(template.generic_task?).to be false
    end
  end

  describe '#create_task_for' do
    let(:member) { Member.create!(name: 'Test Member') }

    it 'creates a new task from the template' do
      template = TaskTemplate.create!(
        title: 'Test Template',
        description: 'Test description',
        difficulty: 'silver',
        category: kitchen_category
      )

      expect {
        template.create_task_for(member: member)
      }.to change(Task, :count).by(1)
    end

    it 'creates a task with correct attributes' do
      template = TaskTemplate.create!(
        title: 'Test Template',
        description: 'Test description',
        difficulty: 'silver',
        category: kitchen_category
      )

      task = template.create_task_for(member: member)

      expect(task.title).to eq('Test Template')
      expect(task.description).to eq('Test description')
      expect(task.difficulty).to eq('silver')
      expect(task.member).to eq(member)
      expect(task.task_template).to eq(template)
      expect(task.status).to eq('todo')
    end

    context 'with Generic Task' do
      it 'creates a task with custom title and difficulty' do
        template = TaskTemplate.create!(
          title: 'Generic Task',
          description: 'Custom task',
          difficulty: 'bronze',
          category: general_category
        )

        task = template.create_task_for(member: member, custom_title: 'Custom Title', custom_difficulty: 'gold')

        expect(task.title).to eq('Custom Title')
        expect(task.difficulty).to eq('gold')
        expect(task.task_template).to eq(template)
      end

      it 'uses template difficulty when no custom difficulty provided' do
        template = TaskTemplate.create!(
          title: 'Generic Task',
          description: 'Custom task',
          difficulty: 'bronze',
          category: general_category
        )

        task = template.create_task_for(member: member, custom_title: 'Custom Title')

        expect(task.title).to eq('Custom Title')
        expect(task.difficulty).to eq('bronze')
      end

      it 'creates regular task when no custom title provided' do
        template = TaskTemplate.create!(
          title: 'Generic Task',
          description: 'Custom task',
          difficulty: 'bronze',
          category: general_category
        )

        task = template.create_task_for(member: member)

        expect(task.title).to eq('Generic Task')
        expect(task.difficulty).to eq('bronze')
      end
    end
  end

  describe '.ordered_for_dashboard' do
    it 'orders templates alphabetically by title, with Generic Task at the bottom' do
      cat = Category.find_or_create_by!(name: 'General')
      t1 = TaskTemplate.create!(title: 'B Task', difficulty: 'bronze', category: cat)
      t2 = TaskTemplate.create!(title: 'A Task', difficulty: 'bronze', category: cat)
      t3 = TaskTemplate.create!(title: 'Generic Task', difficulty: 'bronze', category: cat)
      t4 = TaskTemplate.create!(title: 'Z Task', difficulty: 'bronze', category: cat)
      ordered = TaskTemplate.where(id: [t1.id, t2.id, t3.id, t4.id]).ordered_for_dashboard
      expect(ordered.map(&:title)).to eq(['A Task', 'B Task', 'Z Task', 'Generic Task'])
    end
  end
end
