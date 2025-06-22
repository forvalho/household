# Member Login and Dashboard
get '/members/:id/select' do
  session[:member_id] = params[:id]
  redirect '/dashboard'
end

get '/dashboard' do
  redirect '/' unless member_selected?
  @member_tasks = Task.where(member: current_member).includes(:member).order(:created_at)
  @task_templates = TaskTemplate.all.order(:category, :title)
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
