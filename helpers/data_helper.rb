module DataHelper
  def outstanding_tasks(member)
    member.tasks.where(status: ['todo', 'in_progress']).count
  end

  def calculate_member_points(member, start_date = 30.days.ago)
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    completions.sum { |tc| tc.task.points_value }
  end

  def calculate_member_skips(member, start_date = 30.days.ago)
    member.task_skips.where('skipped_at >= ?', start_date).count
  end

  def calculate_completion_rate(member, start_date)
    total_tasks = member.tasks.where('created_at >= ?', start_date).count
    completed_tasks = member.task_completions.joins(:task).where('completed_at >= ?', start_date).count
    return 0 if total_tasks == 0
    (completed_tasks.to_f / total_tasks * 100).round(1)
  end

  def find_member_or_halt(id)
    member = Member.find_by(id: id)
    halt 404, "Member not found" unless member
    member
  end
end
