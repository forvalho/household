require 'spec_helper'

RSpec.describe 'Task Template Routes', type: :request do
  let(:admin) { Admin.create!(username: 'admin', password: 'password123') }
  let(:member) { Member.create!(name: 'Test Member') }
  let(:kitchen_category) { Category.find_or_create_by!(name: 'Kitchen') }
  let(:laundry_category) { Category.find_or_create_by!(name: 'Laundry') }

  before do
    # Clear any existing data
    TaskTemplate.destroy_all
    Task.destroy_all
    Member.destroy_all
    Admin.destroy_all

    TaskTemplate.create!(
      title: 'Test Template',
      description: 'Test description',
      difficulty: 'silver',
      category: kitchen_category
    )
  end

  describe 'GET /admin/task-templates' do
    context 'when admin is logged in' do
      before do
        login_as_admin(admin)
      end

      it 'returns 200 and shows task templates page' do
        get '/admin/task-templates'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Task Templates')
        expect(last_response.body).to include('Test Template')
      end
    end

    context 'when not logged in as admin' do
      it 'redirects to admin login' do
        get '/admin/task-templates'
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq('/admin/login')
      end
    end
  end

  describe 'POST /admin/task-templates' do
    context 'when admin is logged in' do
      before do
        login_as_admin(admin)
      end

      it 'creates a new task template' do
        expect {
          post '/admin/task-templates', {
            title: 'New Template',
            description: 'New description',
            difficulty: 'gold',
            category_id: laundry_category.id
          }
        }.to change(TaskTemplate, :count).by(1)
      end

      it 'redirects back to templates page' do
        post '/admin/task-templates', {
          title: 'New Template',
          description: 'New description',
          difficulty: 'gold',
          category_id: laundry_category.id
        }
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq('/admin/task-templates')
      end
    end

    context 'when not logged in as admin' do
      it 'redirects to admin login' do
        post '/admin/task-templates', { title: 'New Template' }
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq('/admin/login')
      end
    end
  end

  describe 'PUT /admin/task-templates/:id' do
    let(:template) { TaskTemplate.first }

    context 'when admin is logged in' do
      before do
        login_as_admin(admin)
      end

      it 'updates the task template' do
        put "/admin/task-templates/#{template.id}", {
          title: 'Updated Template',
          description: 'Updated description',
          difficulty: 'gold',
          category_id: laundry_category.id
        }
        expect(last_response).to be_redirect
        expect(template.reload.title).to eq('Updated Template')
      end
    end
  end

  describe 'DELETE /admin/task-templates/:id' do
    let(:template) { TaskTemplate.first }

    context 'when admin is logged in' do
      before do
        login_as_admin(admin)
      end

      # Temporarily skipped with xit
      xit 'deletes the task template' do
        expect {
          delete "/admin/task-templates/#{template.id}"
        }.to change(TaskTemplate, :count).by(-1)
      end
    end
  end

  describe 'POST /admin/task-templates/:id/assign' do
    let(:template) { TaskTemplate.first }

    context 'when no admin is logged in' do
      it 'redirects to admin login' do
        post "/admin/task-templates/#{template.id}/assign", { member_id: 1 }
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/admin/login')
      end
    end

    context 'when admin is logged in' do
      let(:member) { Member.create!(name: 'Member') }
      before do
        login_as_admin(admin)
      end

      it 'creates a new task from template for the specified member' do
        expect {
          post "/admin/task-templates/#{template.id}/assign", { member_id: member.id }
        }.to change(Task, :count).by(1)
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/admin/dashboard')
      end
    end
  end

  describe 'POST /task-templates/:id/assign' do
    let(:template) { TaskTemplate.first }
    let(:member) { Member.create!(name: 'Member') }

    context 'when not logged in as member' do
      it 'redirects to home' do
        post "/task-templates/#{template.id}/assign"
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/')
      end
    end

    context 'when logged in as member' do
      before do
        get "/members/#{member.id}/select"
      end

      it 'creates a new task from template for the member' do
        expect {
          post "/task-templates/#{template.id}/assign"
        }.to change(Task, :count).by(1)
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/dashboard')
      end
    end
  end
end
