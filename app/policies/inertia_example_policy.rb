# frozen_string_literal: true

# 后台示例页（版本信息）授权：纳入 Admin 鉴权红线，按权限点 inertia_example:view 判定。
class InertiaExamplePolicy < ApplicationPolicy
  def view? = user.has_permission?("inertia_example:view")
end
