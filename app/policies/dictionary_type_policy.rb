# frozen_string_literal: true

# 字典类型管理授权
class DictionaryTypePolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:dict:type:list")
  def show?   = user.has_permission?("system:dict:type:list")
  def create? = user.has_permission?("system:dict:type:create")
  def update? = user.has_permission?("system:dict:type:edit")
  def destroy? = user.has_permission?("system:dict:type:delete")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集）。
  def required_scope_permission = "system:dict:type:list"
end
