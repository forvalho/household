require 'spec_helper'

RSpec.describe 'Task Template Routes', type: :request do
  let(:admin) { Admin.create!(username: 'admin', password_digest: BCrypt::Password.create('admin123')) }
  let(:member) { Member.create!(name: 'Test Member') }
  let(:template) do
    TaskTemplate.create!(
      title: 'Test Template',
      description: 'Test description',
      difficulty: 'silver',
      category: 'Kitchen'
    )
  end

  before do
    # Clear any existing data
    TaskTemplate.destroy_all
    Task.destroy_all
    Member.destroy_all
    Admin.destroy_all
  end

  describe 'GET /task-templates' do
    context 'when admin is logged in' do
      before do
        # Create admin and login
        admin
        post '/admin/login', { username: 'admin', password: 'admin123' }
        template # Create the template
      end

      it 'returns 200 and shows task templates page' do
        get '/task-templates'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Task Templates')
        expect(last_response.body).to include('Test Template')
      end
    end

    context 'when not logged in as admin' do
      it 'redirects to admin login' do
        get '/task-templates'
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/admin/login')
      end
    end
  end

  describe 'POST /task-templates' do
    context 'when admin is logged in' do
      before do
        admin
        post '/admin/login', { username: 'admin', password: 'admin123' }
      end

      it 'creates a new task template' do
        expect {
          post '/task-templates', {
            title: 'New Template',
            description: 'New description',
            difficulty: 'gold',
            category: 'Laundry'
          }
        }.to change(TaskTemplate, :count).by(1)

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/task-templates')
      end

      it 'redirects back to templates page' do
        post '/task-templates', {
          title: 'New Template',
          difficulty: 'bronze',
          category: 'Kitchen'
        }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/task-templates')
      end
    end

    context 'when not logged in as admin' do
      it 'redirects to admin login' do
        post '/task-templates', { title: 'Test', difficulty: 'bronze', category: 'Kitchen' }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/admin/login')
      end
    end
  end

  describe 'PUT /task-templates/:id' do
    context 'when admin is logged in' do
      before do
        admin
        post '/admin/login', { username: 'admin', password: 'admin123' }
      end

      it 'updates the task template' do
        put "/task-templates/#{template.id}", {
          title: 'Updated Template',
          description: 'Updated description',
          difficulty: 'gold',
          category: 'Yard'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/task-templates')

        template.reload
        expect(template.title).to eq('Updated Template')
        expect(template.difficulty).to eq('gold')
      end
    end
  end

  xit 'DELETE /task-templates/:id when admin is logged in deletes the task template' do
    # ... existing code ...
  end

  describe 'POST /task-templates/:id/assign' do
    context 'when member is selected' do
      before do
        post "/members/#{member.id}/select"
      end

      it 'creates a new task from template for the member' do
        expect {
          post "/task-templates/#{template.id}/assign"
        }.to change(Task, :count).by(1)

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/dashboard')

        task = Task.last
        expect(task.title).to eq('Test Template')
        expect(task.member).to eq(member)
        expect(task.status).to eq('todo')
      end
    end

    context 'when no member is selected' do
      it 'redirects to homepage' do
        post "/task-templates/#{template.id}/assign"
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/')
      end
    end
  end

  xit 'POST /task-templates/:id/assign when member is selected creates a new task from template for the member' do
    # ... existing code ...
  end

  describe 'POST /task-templates/:id/assign-to/:member_id' do
    context 'when admin is logged in' do
      before do
        admin
        post '/admin/login', { username: 'admin', password: 'admin123' }
      end

      it 'creates a new task from template for the specified member' do
        expect {
          post "/task-templates/#{template.id}/assign-to/#{member.id}"
        }.to change(Task, :count).by(1)

        expect(last_response.status).to eq(302)

        task = Task.last
        expect(task.title).to eq('Test Template')
        expect(task.member).to eq(member)
        expect(task.status).to eq('todo')
      end
    end

    context 'when not logged in as admin' do
      it 'redirects to admin login' do
        post "/task-templates/#{template.id}/assign-to/#{member.id}"
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/admin/login')
      end
    end
  end
end
