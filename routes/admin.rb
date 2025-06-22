class App < Sinatra::Base
  namespace '/admin' do
    # Admin Login
    get '/login' do
      erb :'admin/login'
    end

    post '/login' do
      admin = Admin.find_by(username: params[:username])
      if admin && BCrypt::Password.new(admin.password_digest) == params[:password]
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
      erb :'admin/dashboard', layout: :'admin/layout'
    end

    # Member Management (for Admins)
    get '/members' do
      @members = Member.all
      erb :'admin/members', layout: :'admin/layout'
    end

    post '/members' do
      member = Member.new(name: params[:name], avatar_url: params[:avatar_url])

      if member.save
        set_flash('success', 'Member created successfully!')
      else
        set_flash('error', 'Error creating member')
      end
      redirect '/admin/members'
    end

    post '/members/:id' do
      @member = find_member_or_halt(params[:id])
      if @member.update(name: params[:name], avatar_url: params[:avatar_url])
        set_flash('success', 'Member updated successfully!')
        redirect '/admin/members'
      else
        set_flash('error', 'Error updating member: ' + @member.errors.full_messages.join(', '))
        redirect '/admin/members'
      end
    end

    # Admin Management
    get '/admins' do
      @admins = Admin.all
      erb :'admin/admins', layout: :'admin/layout'
    end

    post '/admins' do
      password_digest = BCrypt::Password.create(params[:password])
      admin = Admin.new(username: params[:username], password_digest: password_digest)

      if admin.save
        set_flash('success', 'Admin created successfully!')
      else
        set_flash('error', 'Error creating admin: ' + admin.errors.full_messages.join(', '))
      end
      redirect '/admin/admins'
    end

    # Reporting (for Admins)
    get '/reports' do
      @members = Member.where(active: true)
      @period = params[:period] || '30'
      @start_date = @period.to_i.days.ago

      @member_stats = @members.map do |member|
        total_tasks = member.tasks.where('created_at >= ?', @start_date).count
        completed_tasks = member.task_completions.where('completed_at >= ?', @start_date).count
        completion_rate = total_tasks > 0 ? ((completed_tasks.to_f / total_tasks) * 100).round : 0

        {
          member: member,
          points: calculate_member_points(member, @start_date),
          medals: calculate_member_medals(member, @start_date),
          completions: completed_tasks,
          completion_rate: completion_rate
        }
      end

      # Calculate Performance Score relative to the top performer
      max_points = @member_stats.map { |s| s[:points] }.max.to_f
      @member_stats.each do |stat|
        stat[:performance_score] = max_points > 0 ? ((stat[:points] / max_points) * 100).round : 0
      end

      erb :'admin/reports', layout: :'admin/layout'
    end
  end
end
