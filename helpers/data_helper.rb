module DataHelper
  def outstanding_tasks(member)
    member.tasks.where(status: ['todo', 'in_progress']).count
  end

  def calculate_member_points(member, start_date = 30.days.ago)
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    completions.sum { |tc| tc.task.points_value }
  end

  def calculate_member_medals(member, start_date = 30.days.ago)
    completions = member.task_completions.joins(:task).where('completed_at >= ?', start_date)
    medals = completions.group_by { |tc| tc.task.medal }
    {
      gold: medals['gold']&.count || 0,
      silver: medals['silver']&.count || 0,
      bronze: medals['bronze']&.count || 0
    }
  end

  def calculate_member_skips(member, start_date = 30.days.ago)
    member.task_skips.where('skipped_at >= ?', start_date).count
  end

  def find_member_or_halt(id)
    member = Member.find_by(id: id)
    halt 404, "Member not found" unless member
    member
  end
end
