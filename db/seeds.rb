# frozen_string_literal: true

# 默认超级管理员（四期接 ActionPolicy 时按 super_admin 短路放行）。
# 用户名 / 手机 / 邮箱 三种方式 + 密码均可登录。
User.find_or_create_by!(username: "admin") do |u|
  u.email = "admin@qingwuxu.dev"
  u.phone = "13800000000"
  u.password = "admin123456"
  u.super_admin = true
  u.status = :enabled
end

puts "Seed 完成：admin / 13800000000 / admin123456（用户名 / 手机 / 邮箱 + 密码 均可登录）"
