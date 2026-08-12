# frozen_string_literal: true

# 文件管理授权（按权限点判定：查看 / 上传 / 删除 三态分离）。
class FilePolicy < ApplicationPolicy
  def list?   = user.has_permission?("system:file:list")
  def upload? = user.has_permission?("system:file:upload")
  def delete? = user.has_permission?("system:file:delete")
end
