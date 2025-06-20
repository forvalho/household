require 'spec_helper'

RSpec.describe Member, type: :model do
  describe 'validations' do
    it 'is valid with a unique name' do
      Member.create!(name: 'Test Member')
      member = Member.new(name: 'Another Member')
      expect(member).to be_valid
    end

    it 'is invalid without a name' do
      member = Member.new(name: nil)
      expect(member).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      Member.create!(name: 'Test Member')
      member = Member.new(name: 'Test Member')
      expect(member).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many tasks' do
      association = described_class.reflect_on_association(:tasks)
      expect(association.macro).to eq :has_many
    end

    it 'has many task_completions' do
        association = described_class.reflect_on_association(:task_completions)
        expect(association.macro).to eq :has_many
    end

    it 'has many task_skips' do
        association = described_class.reflect_on_association(:task_skips)
        expect(association.macro).to eq :has_many
    end
  end
end
