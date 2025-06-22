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
  template = TaskTemplate.find(params[:id])

  if admin_logged_in?
    # Admin can assign to any member
    member = Member.find(params[:member_id])
    if template.generic_task? && params[:custom_title].present?
      task = template.create_task_for(member, custom_title: params[:custom_title], custom_difficulty: params[:custom_difficulty])
      set_flash('success', "Custom task '#{params[:custom_title]}' assigned to #{member.name}!")
    else
      task = template.create_task_for(member)
      set_flash('success', "Task '#{template.title}' assigned to #{member.name}!")
    end
  elsif member_selected?
    # Member can only assign to themselves
    # If member_id is provided, validate it's the current member
    if params[:member_id].present?
      if params[:member_id].to_i == current_member.id
        member = current_member
      else
        set_flash('error', 'You can only assign tasks to yourself.')
        redirect '/dashboard'
        return
      end
    else
      # Backward compatibility: no member_id provided, assign to current member
      member = current_member
    end

    if template.generic_task? && params[:custom_title].present?
      task = template.create_task_for(member, custom_title: params[:custom_title], custom_difficulty: params[:custom_difficulty])
      set_flash('success', "Custom task '#{params[:custom_title]}' assigned to you!")
    else
      task = template.create_task_for(member)
      set_flash('success', "Task '#{template.title}' assigned to you!")
    end
  else
    set_flash('error', 'You must be logged in to assign tasks.')
    redirect '/'
    return
  end

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
  unless admin_logged_in? || (member_selected? && task.member_id == current_member.id)
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

  # A member can only complete their own task
  if task.member_id == current_member.id
    TaskCompletion.create!(task: task, member: current_member, completed_at: Time.now, notes: params[:notes])
    task.update(status: 'done')
    set_flash('success', "Task completed! +#{task.points_value} points")
  else
    set_flash('error', 'You can only complete your own tasks')
  end

  redirect '/dashboard'
end

# Assign or unassign a task
patch '/tasks/:id/assignee' do
  task = Task.find(params[:id])
  new_member_id = params[:member_id].presence

  # Check permissions
  unless admin_logged_in? || (member_selected? && task.member_id == current_member.id)
    set_flash('error', 'You can only modify your own tasks')
    return redirect '/dashboard'
  end

  # If unassigning (new_member_id is empty), destroy the task
  if new_member_id.blank?
    task.destroy
    set_flash('info', 'Task removed')
    redirect '/dashboard'
  end

  # If assignment doesn't change, just redirect
  if task.member_id == new_member_id.to_i
    redirect '/dashboard'
  end

  # Update assignment
  task.update(member_id: new_member_id)
  set_flash('success', 'Task assigned successfully')
  redirect '/dashboard'
end

# Create a custom task (from Generic Task modal)
post '/custom-tasks' do
  redirect '/' unless member_selected?

  if admin_logged_in?
    # Admin can assign to any member
    member = Member.find(params[:member_id])
  else
    # Member can only assign to themselves
    member = current_member
  end

  task = Task.create!(
    title: params[:title],
    difficulty: params[:difficulty],
    category: params[:category],
    member: member,
    status: 'todo'
  )

  set_flash('success', "Custom task '#{task.title}' created and assigned to #{member.name}!")
  redirect '/dashboard'
end
