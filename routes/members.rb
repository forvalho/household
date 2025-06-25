# Member Login and Dashboard
get '/members/:id/select' do
  session[:member_id] = params[:id]
  redirect '/dashboard'
end

get '/dashboard' do
  redirect '/' unless member_selected?

  # Parse date filter parameter
  date_filter = params[:date_filter] || 'today'
  custom_date_from = params[:custom_date_from]
  custom_date_to = params[:custom_date_to]

  # Backend validation for custom date range
  if date_filter == 'custom'
    today = Date.today
    if custom_date_from.blank? || custom_date_to.blank?
      set_flash('error', 'Both dates are required for a custom range.')
      redirect '/dashboard'
    end
    begin
      from_date = Date.parse(custom_date_from)
      to_date = Date.parse(custom_date_to)
    rescue ArgumentError
      set_flash('error', 'Invalid date format for custom range.')
      redirect '/dashboard'
    end
    if from_date > today || to_date > today
      set_flash('error', 'Dates cannot be in the future.')
      redirect '/dashboard'
    end
    if from_date > to_date
      set_flash('error', 'The start date must be before or equal to the end date.')
      redirect '/dashboard'
    end
  end

  # Determine the date range based on filter
  start_date, end_date = case date_filter
  when 'today'
    [Date.today, Date.today]
  when 'yesterday'
    [Date.yesterday, Date.yesterday]
  when 'this_week'
    [Date.today.beginning_of_week, Date.today.end_of_week]
  when 'last_week'
    [1.week.ago.beginning_of_week, 1.week.ago.end_of_week]
  when 'this_month'
    [Date.today.beginning_of_month, Date.today.end_of_month]
  when 'last_month'
    [1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
  when 'custom'
    if custom_date_from.present? && custom_date_to.present?
      [Date.parse(custom_date_from), Date.parse(custom_date_to)]
    elsif custom_date_from.present?
      d = Date.parse(custom_date_from)
      [d, d]
    elsif custom_date_to.present?
      d = Date.parse(custom_date_to)
      [d, d]
    else
      [Date.today, Date.today]
    end
  else
    [Date.today, Date.today]
  end

  # Get all tasks for the member within the date range
  all_tasks = Task.where(member: current_member)
                  .includes(:member, :category)
                  .where(updated_at: start_date.beginning_of_day..end_date.end_of_day)
                  .order(updated_at: :desc, title: :asc)

  # Group tasks by status for the board (no longer by day)
  @tasks_by_status = { todo: [], in_progress: [], done: [] }
  all_tasks.each do |task|
    @tasks_by_status[task.status.to_sym] << task
  end

  # Store filter state for the view
  @current_date_filter = date_filter
  @current_custom_date_from = custom_date_from
  @current_custom_date_to = custom_date_to
  @start_date = start_date
  @end_date = end_date

  @task_templates = TaskTemplate.ordered_for_dashboard
  @task_templates_by_category = @task_templates.group_by { |t| t.category }
  erb :'member/dashboard'
end

# --- Member-facing routes ---
get '/profile/edit' do
  redirect '/' unless member_selected?
  @member = current_member
  erb :'member/edit_profile'
end

post '/profile' do
  redirect '/' unless member_selected?
  @member = current_member
  if @member.update(name: params[:name], avatar_url: params[:avatar_url])
    set_flash('success', 'Profile updated successfully!')
    redirect '/dashboard'
  else
    set_flash('error', 'Error updating profile: ' + @member.errors.full_messages.join(', '))
    erb :'member/edit_profile'
  end
end

get '/members/new' do
  halt 403, 'Member signup is disabled' unless settings.allow_member_signup
  erb :'members/new'
end
