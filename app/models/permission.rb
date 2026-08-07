# frozen_string_literal: true

# 权限点：RBAC 最小授权单元（对标若依权限字符，如 system:user:list）。
class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
