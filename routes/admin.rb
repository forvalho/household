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
    @members = Member.where(active: true)
    @tasks_by_member = Task.includes(:member).order(:created_at).group_by(&:member)
    erb :'admin/dashboard'
  end

  # Task Management (for Admins)
  post '/tasks' do
    task = Task.new(
      title: params[:title],
      description: params[:description],
      difficulty: params[:difficulty],
      category: params[:category],
      member_id: params[:member_id],
      due_date: params[:due_date],
      points: params[:points] || 1
    )

    if task.save
      set_flash('success', 'Task created successfully!')
    else
      set_flash('error', 'Error creating task')
    end
    redirect back
  end

  # Member Management (for Admins)
  get '/members' do
    @members = Member.all
    erb :'admin/members'
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
    erb :'admin/admins'
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
      {
        member: member,
        points: calculate_member_points(member, @start_date),
        skips: calculate_member_skips(member, @start_date),
        completions: member.task_completions.where('completed_at >= ?', @start_date).count,
        completion_rate: calculate_completion_rate(member, @start_date)
      }
    end

    erb :'admin/reports'
  end
end
