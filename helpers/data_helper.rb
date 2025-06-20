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
    end_date = Date.today

    # Numerator: Count actual completions within the reporting period.
    completed_count = member.task_completions.where(completed_at: start_date..end_date.end_of_day).count

    # Denominator: Calculate the number of *expected* completions.
    expected_count = 0
    member.tasks.each do |task|
      # Determine the effective start date for this task within the reporting window.
      task_period_start = [task.created_at.to_date, start_date].max
      next if task_period_start > end_date

      case task.recurrence
      when 'none'
        # A non-recurring task is expected to be completed once.
        expected_count += 1
      when 'daily'
        # Expected once for each day the task was active in the period.
        expected_count += (end_date - task_period_start).to_i + 1
      when 'weekly'
        # Expected once for each week the task was active in the period.
        expected_count += ((end_date - task_period_start).to_i / 7) + 1
      end
    end

    return 0 if expected_count == 0
    (completed_count.to_f / expected_count * 100).round(1)
  end

  def find_member_or_halt(id)
    member = Member.find_by(id: id)
    halt 404, "Member not found" unless member
    member
  end
end
