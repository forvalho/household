# routes/main.rb

get '/' do
  @members = Member.where(active: true).order(:name)
  erb :index
end

get '/leaderboard' do
  @period = params[:period] || '30'
  start_date = @period.to_i.days.ago
  members = Member.where(active: true)

  # Calculate stats for each member
  stats = members.map do |member|
    {
      member: member,
      points: calculate_member_points(member, start_date),
      medals: calculate_member_medals(member, start_date),
      completions: member.task_completions.where('completed_at >= ?', start_date).count
    }
  end

  # Sort by points to find the top performer
  sorted_stats = stats.sort_by { |s| -s[:points] }

  # Calculate performance score relative to the top performer
  max_points = sorted_stats.first&.dig(:points).to_f
  @leaderboard_stats = sorted_stats.map do |stat|
    performance_score = max_points > 0 ? ((stat[:points] / max_points) * 100).round : 0
    stat.merge(performance_score: performance_score)
  end

  erb :leaderboard
end
