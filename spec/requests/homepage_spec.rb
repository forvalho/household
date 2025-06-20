require 'spec_helper'

RSpec.describe 'Homepage', type: :request do
  it 'loads successfully' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'shows a list of active members' do
    Member.create!(name: 'Test Member', active: true)
    Member.create!(name: 'Inactive Member', active: false)

    get '/'

    expect(last_response.body).to include('Test Member')
    expect(last_response.body).not_to include('Inactive Member')
  end
end
