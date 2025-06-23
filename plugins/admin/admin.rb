# plugins/admin/admin.rb
require 'sinatra/base'
require 'sinatra/namespace'
require_relative 'helpers'

module Household
  module Admin
    def self.registered(app)
      # --- Configuration ---
      # Use Household::ROOT to get the plugin's views path
      plugin_views_path = File.join(Household::ROOT, 'plugins', 'admin', 'views')
      app.set :plugin_views_path, plugin_views_path

      # Serve static files (CSS) from this plugin's public folder
      app.use Rack::Static, urls: ['/admin-assets'], root: File.expand_path('../public', __FILE__)

      # --- Helpers ---
      app.helpers Household::Admin::Helpers

      # This filter runs for all admin pages and prepares the sidebar
      app.before '/admin/*' do
        # Don't show sidebar on the login page
        pass if request.path_info == '/admin/login'

        # Set variables for the main layout to use
        @wrapper_class = 'admin-content-wrapper'
        @sidebar_html = render_sidebar
        @main_content_class = 'admin-main-content'
      end

      # This filter runs on every request to add the admin nav links if logged in
      app.before do
        add_admin_nav_links
      end

      # --- Routes ---
      app.namespace '/admin' do
        # Admin Login
        get '/login' do
          erb :login, views: plugin_views_path, layout: false
        end

        post '/login' do
          admin = ::Admin.find_by(username: params[:username])
          if admin && admin.authenticate(params[:password])
            session[:admin_id] = admin.id
            set_flash('success', 'Welcome back, Admin!')
            redirect '/admin/dashboard'
          else
            set_flash('error', 'Invalid admin username or password')
            redirect '/admin/login'
          end
        end

        get '/logout' do
          session.clear
          set_flash('success', 'You have been logged out')
          redirect '/'
        end

        before '/*' do
          pass if request.path_info == '/admin/login'
          require_admin_login
        end

        get '/dashboard' do
          @members = Member.where(active: true).order(:name)
          @tasks_by_member = Task.includes(:member).order(:created_at).group_by(&:member_id)
          @tasks_by_status = Task.order(:created_at).group_by(&:status)
          erb :dashboard, views: plugin_views_path, layout: :layout, layout_options: { views: File.join(Household::ROOT, 'views') }
        end

        # Member Management
        get '/members' do
          @members = Member.all
          erb :members, views: plugin_views_path, layout: :layout, layout_options: { views: File.join(Household::ROOT, 'views') }
        end

        post '/members' do
          member = Member.new(name: params[:name], avatar_url: params[:avatar_url])
          if member.save
            set_flash('success', 'Member created successfully!')
          else
            set_flash('error', 'Error creating member: ' + member.errors.full_messages.join(', '))
          end
          redirect '/admin/members'
        end

        post '/members/:id' do
          @member = find_member_or_halt(params[:id])
          if @member.update(name: params[:name], avatar_url: params[:avatar_url])
            set_flash('success', 'Member updated successfully!')
          else
            set_flash('error', 'Error updating member: ' + @member.errors.full_messages.join(', '))
          end
          redirect '/admin/members'
        end

        # Admin Management
        get '/admins' do
          @admins = ::Admin.all
          erb :admins, views: plugin_views_path, layout: :layout, layout_options: { views: File.join(Household::ROOT, 'views') }
        end

        post '/admins' do
          admin = ::Admin.new(username: params[:username], password: params[:password], password_confirmation: params[:password])
          if admin.save
            set_flash('success', 'Admin created successfully!')
          else
            set_flash('error', 'Error creating admin: ' + admin.errors.full_messages.join(', '))
          end
          redirect '/admin/admins'
        end

        # Reporting
        get '/reports' do
          @members = Member.where(active: true)
          @period = params[:period] || '30'
          start_date = @period.to_i.days.ago

          @member_stats = @members.map do |member|
            {
              member: member,
              points: calculate_member_points(member, start_date),
              medals: calculate_member_medals(member, start_date),
              completions: member.task_completions.where('completed_at >= ?', start_date).count,
              completion_rate: calculate_completion_rate(member, start_date)
            }
          end

          max_points = @member_stats.map { |s| s[:points] }.max.to_f
          @member_stats.each do |stat|
            stat[:performance_score] = max_points > 0 ? ((stat[:points] / max_points) * 100).round : 0
          end

          erb :reports, views: plugin_views_path, layout: :layout, layout_options: { views: File.join(Household::ROOT, 'views') }
        end

        # --- Task Template Management ---
        get '/task-templates' do
          @templates = TaskTemplate.all.order(:category, :title)
          erb :task_templates, views: plugin_views_path, layout: :layout, layout_options: { views: File.join(Household::ROOT, 'views') }
        end

        post '/task-templates' do
          template = TaskTemplate.new(
            title: params[:title],
            description: params[:description],
            difficulty: params[:difficulty],
            category: Category.find(params[:category_id])
          )

          if template.save
            set_flash('success', 'Task template created successfully!')
          else
            set_flash('error', 'Error creating task template')
          end
          redirect '/admin/task-templates'
        end

        put '/task-templates/:id' do
          template = TaskTemplate.find(params[:id])
          if template.update(
            title: params[:title],
            description: params[:description],
            difficulty: params[:difficulty],
            category: Category.find(params[:category_id])
          )
            set_flash('success', 'Task template updated successfully!')
          else
            set_flash('error', 'Error updating template: ' + template.errors.full_messages.join(', '))
          end
          redirect '/admin/task-templates'
        end

        # Assign a task template to a member (admin only)
        post '/task-templates/:id/assign' do
          require_admin_login
          template = TaskTemplate.find(params[:id])
          member = Member.find(params[:member_id])
          if template.generic_task? && params[:custom_title].present?
            task = template.create_task_for(member: member, custom_title: params[:custom_title], custom_difficulty: params[:custom_difficulty])
            set_flash('success', "Custom task '#{params[:custom_title]}' assigned to #{member.name}!")
          else
            task = template.create_task_for(member: member)
            set_flash('success', "Task '#{template.title}' assigned to #{member.name}!")
          end
          redirect '/admin/dashboard'
        end

        # Admin can assign template to any member
        post '/task-templates/:id/assign-to/:member_id' do
          template = TaskTemplate.find(params[:id])
          member = Member.find(params[:member_id])

          task = template.create_task_for(member: member)

          set_flash('success', "Task '#{template.title}' assigned to #{member.name}!")
          redirect back
        end

        delete '/task-templates/:id' do
          template = TaskTemplate.find(params[:id])
          template.destroy
          set_flash('success', 'Task template deleted!')
          redirect '/admin/task-templates'
        end
      end
    end
  end
end
