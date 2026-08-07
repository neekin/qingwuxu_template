# frozen_string_literal: true

# 角色：权限点的打包容器（最小授权单元是 permission，不是角色）。
class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  enum :status, { disabled: 0, enabled: 1 }, default: :enabled

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
