# frozen_string_literal: true

# 用户 ⇄ 角色 关联（纯配置，无业务逻辑）。
class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :role_id }
end
