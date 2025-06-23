module DataHelper
  def outstanding_tasks(member)
    member.tasks.where(status: ['todo', 'in_progress']).count
  end

  def calculate_member_points(member, start_date = 30.days.ago)
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    completions.sum { |tc| tc.task.points_value }
  end

  def calculate_member_medals(member, start_date = 30.days.ago)
    medals = { gold: 0, silver: 0, bronze: 0 }
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    completions.each do |completion|
      difficulty = completion.task.difficulty.to_sym
      medals[difficulty] += 1 if medals.key?(difficulty)
    end
    medals
  end

  def calculate_completion_rate(member, period)
    # Get all tasks that were active during the period
    tasks = member.tasks.where('created_at <= ?', period.end)

    return 0.0 if tasks.empty?

    total_expected = tasks.count
    total_completed = tasks.where(status: 'done').count

    return 0.0 if total_expected == 0
    (total_completed.to_f / total_expected * 100).round(1)
  end

  def find_member_or_halt(id)
    member = Member.find_by(id: id)
    halt 404, "Member not found" unless member
    member
  end
end
