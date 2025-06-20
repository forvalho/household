require 'spec_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    it 'is valid with a unique username' do
      Admin.create!(username: 'testadmin', password_digest: 'password')
      admin = Admin.new(username: 'testadmin2', password_digest: 'password')
      expect(admin).to be_valid
    end

    it 'is invalid without a username' do
      admin = Admin.new(username: nil, password_digest: 'password')
      expect(admin).not_to be_valid
    end

    it 'is invalid with a duplicate username' do
      Admin.create!(username: 'testadmin', password_digest: 'password')
      admin = Admin.new(username: 'testadmin', password_digest: 'password')
      expect(admin).not_to be_valid
    end
  end
end
