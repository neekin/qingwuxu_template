# frozen_string_literal: true

# 角色 ⇄ 权限点 关联（纯配置，无业务逻辑）。
class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates :role_id, uniqueness: { scope: :permission_id }
end
