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
    halt 403, { success: false, message: 'Permission denied' }.to_json
  end

  task.update(status: params[:status])

  content_type :json
  { success: true, task_id: task.id, status: task.status }.to_json
end

post '/tasks/:id/complete' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  unless task.member_id == current_member.id
    set_flash('error', 'You can only complete your own tasks')
    redirect '/dashboard'
  end

  TaskCompletion.create!(task: task, member: current_member, completed_at: Time.now, notes: params[:notes])
  task.update(status: 'done')

  set_flash('success', "Task completed! +#{task.points} points")
  redirect '/dashboard'
end

post '/tasks/:id/skip' do
  redirect '/' unless member_selected?
  task = Task.find(params[:id])

  unless task.member_id == current_member.id
    set_flash('error', 'You can only skip your own tasks')
    redirect '/dashboard'
  end

  TaskSkip.create!(task: task, member: current_member, skipped_at: Time.now, reason: params[:reason])
  task.update(status: 'skipped')

  set_flash('warning', 'Task skipped with reason recorded')
  redirect '/dashboard'
end
