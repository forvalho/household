# Task Template Management
get '/task-templates' do
  require_admin_login
  @templates = TaskTemplate.all.order(:category, :title)
  erb :'admin/task_templates'
end

post '/task-templates' do
  require_admin_login

  template = TaskTemplate.new(
    title: params[:title],
    description: params[:description],
    difficulty: params[:difficulty],
    category: params[:category]
  )

  if template.save
    set_flash('success', 'Task template created successfully!')
  else
    set_flash('error', 'Error creating task template')
  end
  redirect '/task-templates'
end

put '/task-templates/:id' do
  require_admin_login
  template = TaskTemplate.find(params[:id])

  if template.update(
    title: params[:title],
    description: params[:description],
    difficulty: params[:difficulty],
    category: params[:category]
  )
    set_flash('success', 'Task template updated successfully!')
  else
    set_flash('error', 'Error updating task template')
  end
  redirect '/task-templates'
end

# Assign a task template to a member (creates a new task from template)
post '/task-templates/:id/assign' do
  redirect '/' unless member_selected?

  template = TaskTemplate.find(params[:id])
  member = current_member

  # Create a new task from the template
  task = template.create_task_for(member)

  set_flash('success', "Task '#{template.title}' assigned to you!")
  redirect '/dashboard'
end

# Admin can assign template to any member
post '/task-templates/:id/assign-to/:member_id' do
  require_admin_login

  template = TaskTemplate.find(params[:id])
  member = Member.find(params[:member_id])

  task = template.create_task_for(member)

  set_flash('success', "Task '#{template.title}' assigned to #{member.name}!")
  redirect back
end

delete '/task-templates/:id' do
  require_admin_login
  template = TaskTemplate.find(params[:id])
  template.destroy
  set_flash('success', 'Task template deleted!')
  redirect '/task-templates'
end

# Task Management (for Admins)
post '/tasks' do
  require_admin_login

  task = Task.new(
    title: params[:title],
    description: params[:description],
    difficulty: params[:difficulty],
    category: params[:category],
    member_id: params[:member_id],
    due_date: params[:due_date],
    points: params[:points] || 1
  )

  # If a member is assigned at creation, the status should be 'todo'
  task.status = 'todo' if task.member_id.present?

  if task.save
    set_flash('success', 'Task created successfully!')
  else
    set_flash('error', 'Error creating task')
  end
  redirect '/dashboard'
end

put '/tasks/:id/status' do
  task = Task.find(params[:id])

  # Allow admin or the assigned member to move tasks
  unless admin_logged_in? || (member_selected? && (task.member_id == current_member.id || task.member_id.nil?))
    if request.content_type == 'application/json'
      halt 403, { success: false, message: 'Permission denied' }.to_json
    else
      set_flash('error', 'Permission denied')
      redirect '/dashboard'
    end
  end

  task.update(status: params[:status])

  if request.content_type == 'application/json'
    content_type :json
    { success: true, task_id: task.id, status: task.status }.to_json
  else
    set_flash('success', "Task status updated to #{params[:status].titleize}")
    redirect '/dashboard'
  end
end

post '/tasks/:id/complete' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  # A member can complete their own task or claim an unassigned one
  if task.member_id.nil? || task.member_id == current_member.id
    TaskCompletion.create!(task: task, member: current_member, completed_at: Time.now, notes: params[:notes])

    updates = { member_id: current_member.id } # Claim the task if it was unassigned
    updates[:status] = 'done'

    task.update(updates)

    set_flash('success', "Task completed! +#{task.points_value} points")
  else
    set_flash('error', 'You can only complete your own tasks')
  end

  redirect '/dashboard'
end

post '/tasks/:id/skip' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  unless task.member_id == current_member.id
    set_flash('error', 'You can only skip your own tasks')
    return redirect '/dashboard'
  end

  TaskSkip.create!(task: task, member: current_member, skipped_at: Time.now, reason: params[:reason])
  task.update(status: 'skipped')

  set_flash('warning', 'Task skipped with reason recorded')
  redirect '/dashboard'
end

# Assign or unassign a task
patch '/tasks/:id/assignee' do
  task = Task.find(params[:id])
  new_member_id = params[:member_id].presence
  current_member_id = task.member_id

  # Check if the assignment is actually changing
  if new_member_id == current_member_id
    # No change needed, just redirect without showing a message
    redirect back
  end

  update_logic = lambda do |new_id|
    updates = { member_id: new_id }
    if current_member_id.nil? && new_id.present?
      # Unassigned -> Assigned
      updates[:status] = 'todo'
    elsif current_member_id.present? && new_id.nil?
      # Assigned -> Unassigned
      updates[:status] = 'unassigned'
    end
    task.update(updates)
    set_flash('success', 'Task assignment updated!')
  end

  if admin_logged_in?
    update_logic.call(new_member_id)
  elsif member_selected?
    if (current_member_id.nil? && new_member_id.to_i == current_member.id) ||
       (current_member_id == current_member.id && new_member_id.blank?)
      update_logic.call(new_member_id)
    else
      set_flash('error', 'You do not have permission to assign this task.')
      redirect '/dashboard' and return
    end
  else
    set_flash('error', 'You must be logged in.')
  end
  redirect back
end
