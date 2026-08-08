# frozen_string_literal: true

# 字典数据项管理授权
class DictionaryDataPolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:dict:data:list")
  def show?   = user.has_permission?("system:dict:data:list")
  def create? = user.has_permission?("system:dict:data:create")
  def update? = user.has_permission?("system:dict:data:edit")
  def destroy? = user.has_permission?("system:dict:data:delete")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集）。
  def required_scope_permission = "system:dict:data:list"
end
