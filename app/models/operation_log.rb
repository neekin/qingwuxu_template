# frozen_string_literal: true

# 操作日志（后台管理操作审计；含查询/新增/修改/删除）。
class OperationLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User", optional: true

  scope :recent, -> { order(created_at: :desc) }
end
