# frozen_string_literal: true

module Admin
  # Solid Queue 任务监控（只读视图：展示队列积压 / 进行中 / 失败 / 已完成统计，
  # 以及最近任务列表）。写操作（重试/清除）留待后续分期，本期仅监控。
  # 数据来源：solid_queue 自带模型（SolidQueue::Job 及其子类表）。
  class SolidQueueJobsController < BaseController
    def index
      authorize! nil, to: :view?, with: SolidQueueJobPolicy
      render inertia: "admin/solid-queue-jobs/index", props: queue_props
    end

    private

    def queue_props
      # 统计各状态任务数（solid_queue 1.6 按状态分表：ready/scheduled/claimed/failed/finished）。
      jobs = SolidQueue::Job
      {
        stats: {
          pending: SolidQueue::ReadyExecution.count + SolidQueue::ScheduledExecution.count,
          running: SolidQueue::ClaimedExecution.count,
          failed: SolidQueue::FailedExecution.count,
          finished: jobs.where.not(finished_at: nil).count
        },
        jobs: jobs.order(created_at: :desc).limit(50).map do |job|
          {
            id: job.id,
            class_name: job.class_name,
            queue_name: job.queue_name,
            priority: job.priority,
            status: job_status(job),
            created_at: job.created_at.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      }
    end

    # jobs 表无 started_at/failed_at 列：finished_at 非空=已完成，否则=待执行。
    def job_status(job)
      job.finished_at.present? ? "finished" : "pending"
    end
  end
end
