# frozen_string_literal: true

# Solid Queue 任务监控页授权（轻量 policy：按权限点 monitor:job:list 判定）。
class SolidQueueJobPolicy < ApplicationPolicy
  def view? = user.has_permission?("monitor:job:list")
end
