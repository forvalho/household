# plugins/admin/admin.rb
require 'sinatra/base'
require 'sinatra/namespace'

# Admin routes (formerly plugin)

# --- Helpers ---
helpers AdminHelper

# Serve static files (CSS) from admin-assets
use Rack::Static, urls: ['/admin-assets'], root: File.expand_path('../public', __dir__)

before '/admin/*' do
  pass if request.path_info == '/admin/login'
  @wrapper_class = 'admin-content-wrapper'
  @sidebar_html = render_sidebar
  @main_content_class = 'admin-main-content'
end

namespace '/admin' do
  # Admin Login
  get '/login' do
    erb :'admin/login', layout: false
  end

  post '/login' do
    admin = Admin.find_by(username: params[:username])
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
    erb :'admin/dashboard', layout: :layout
  end

  # Member Management
  get '/members' do
    @members = Member.all
    erb :'admin/members', layout: :layout
  end

  post '/members' do
    member = Member.new(name: params[:name], avatar_url: params[:avatar_url])
    if member.save
      set_flash('success', 'Member created successfully!')
    else
      set_flash('error', 'Error creating member: ' + member.errors.full_messages.join(', '))
    end
    redirect_back_or_default('/admin/members')
  end

  post '/members/:id' do
    @member = find_member_or_halt(params[:id])
    if @member.update(name: params[:name], avatar_url: params[:avatar_url])
      set_flash('success', 'Member updated successfully!')
    else
      set_flash('error', 'Error updating member: ' + @member.errors.full_messages.join(', '))
    end
    redirect_back_or_default('/admin/members')
  end

  # Admin Management
  get '/admins' do
    @admins = Admin.all
    erb :'admin/admins', layout: :layout
  end

  post '/admins' do
    admin = Admin.new(username: params[:username], password: params[:password], password_confirmation: params[:password])
    if admin.save
      set_flash('success', 'Admin created successfully!')
    else
      set_flash('error', 'Error creating admin: ' + admin.errors.full_messages.join(', '))
    end
    redirect_back_or_default('/admin/admins')
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

    erb :'admin/reports', layout: :layout
  end

  # --- Task Template Management ---
  get '/task-templates' do
    @templates = TaskTemplate.all.order(:category, :title)
    erb :'admin/task_templates', layout: :layout
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
    redirect_back_or_default('/admin/task-templates')
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
    redirect_back_or_default('/admin/task-templates')
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
    redirect_back_or_default('/admin/dashboard')
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
    redirect_back_or_default('/admin/task-templates')
  end

  # Admin Settings
  get '/settings' do
    erb :'admin/settings', layout: :layout
  end

  # Category Management
  get '/categories' do
    @categories = Category.all.order(:name)
    erb :'admin/categories', layout: :layout
  end

  post '/categories' do
    category = Category.new(
      name: params[:name],
      icon: params[:icon],
      color: params[:color]
    )

    if category.save
      set_flash('success', 'Category created successfully!')
    else
      set_flash('error', 'Error creating category: ' + category.errors.full_messages.join(', '))
    end
    redirect_back_or_default('/admin/categories')
  end

  put '/categories/:id' do
    category = Category.find(params[:id])
    if category.update(
      name: params[:name],
      icon: params[:icon],
      color: params[:color]
    )
      set_flash('success', 'Category updated successfully!')
    else
      set_flash('error', 'Error updating category: ' + category.errors.full_messages.join(', '))
    end
    redirect_back_or_default('/admin/categories')
  end

  delete '/categories/:id' do
    category = Category.find(params[:id])
    if category.task_templates.count == 0 && category.tasks.count == 0
      category.destroy
      set_flash('success', 'Category deleted successfully!')
    else
      set_flash('error', 'Cannot delete category with associated tasks or templates')
    end
    redirect_back_or_default('/admin/categories')
  end

  post '/settings' do
    # Checkbox only sends param if checked
    allow = params[:allow_member_signup] == 'true' || params[:allow_member_signup] == 'on'
    Setting.set('allow_member_signup', allow.to_s)
    set_flash('success', 'Settings updated!')
    redirect_back_or_default('/admin/settings')
  end

  post '/settings/avatar_styles' do
    require_admin_login
    enabled = Array(params[:enabled_styles]).map(&:to_s)
    in_use = avatar_style_in_use_counts.keys
    # Prevent disabling any style in use
    if (in_use - enabled).any?
      set_flash('error', 'Cannot disable avatar styles that are currently in use by members.')
      redirect_back_or_default('/admin/settings')
    end
    Setting.set('enabled_avatar_styles', enabled.to_json)
    set_flash('success', 'Avatar style settings updated!')
    redirect_back_or_default('/admin/settings')
  end

  delete '/admin/tasks/:id/reject' do
    require_admin_login
    task = Task.find_by(id: params[:id])
    if task && task.custom_task?
      task.destroy
      set_flash('success', 'Custom task rejected and removed.')
    else
      set_flash('error', 'Task not found or not a custom task.')
    end
    redirect_back_or_default('/admin/dashboard')
  end

  get '/custom-tasks' do
    require_admin_login
    @custom_tasks = Task.custom.includes(:member, :category).order(updated_at: :desc)
    erb :'admin/custom_tasks', layout: :layout
  end
end
