# frozen_string_literal: true

# 菜单管理页授权（轻量 policy：按权限点 menus:view 判定）。
class MenuPolicy < ApplicationPolicy
  def view? = user.has_permission?("menus:view")
end
