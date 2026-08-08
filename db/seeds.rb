# frozen_string_literal: true

# ⚠️ 安全约定（🟡 弱口令清理）：演示数据仅非生产环境注入，生产须用强凭证。
# - 开发 / 测试环境：创建 12 个 demo 用户 + 5 个 demo 角色用于联调与测试。
# - 生产环境：跳过全部演示账户，仅确保 super_admin 初始账户存在，其密码
#   从环境变量 ENV['ADMIN_INITIAL_PASSWORD'] 或 Rails 凭证 credentials[:admin][:initial_password]
#   读取；若两者皆缺，则仅告警、绝不写死弱口令。

# 是否注入演示数据：仅 development / test 环境。
seeding_demo = Rails.env.development? || Rails.env.test?

# 默认超级管理员（四期接 ActionPolicy 时按 super_admin 短路放行）。
# 用户名 / 手机 / 邮箱 三种方式 + 密码均可登录。
User.find_or_create_by!(username: "admin") do |u|
  u.email = "admin@qingwuxu.dev"
  u.phone = "13800000000"
  if seeding_demo
    u.password = "admin123456"
  else
    # 生产：从环境变量 / 凭证读取强口令，缺失则告警，不写死弱口令。
    env_pwd = ENV["ADMIN_INITIAL_PASSWORD"].presence ||
              Rails.application.credentials.dig(:admin, :initial_password).presence
    if env_pwd.blank?
      Rails.logger.warn "⚠️  生产环境未配置超级管理员密码：" \
                        "请设置 ENV['ADMIN_INITIAL_PASSWORD'] 或 credentials[:admin][:initial_password] 为强口令。"
    else
      u.password = env_pwd
    end
  end
  u.super_admin = true
  u.status = :enabled
end

# ---- RBAC 角色 / 权限 / 菜单（幂等，对齐 app/frontend/config/adminMenu.tsx）----
rbac_permissions = [
  %w[dashboard:view 仪表盘查看 dashboard],
  %w[system:manage 系统管理 system],
  %w[system:user:list 用户管理 system/user],
  %w[system:role:list 角色管理 system/role],
  %w[system:menu:list 菜单管理 system/menu],
  %w[system:dept:list 部门管理 system/dept],
  %w[system:dept:create 部门新增 system/dept],
  %w[system:dept:edit 部门编辑 system/dept],
  %w[system:dept:delete 部门删除 system/dept],
  %w[monitor:manage 系统监控 monitor],
  %w[monitor:operlog:list 操作日志 monitor/operlog],
  %w[monitor:loginlog:list 登录日志 monitor/loginlog],
  %w[user:profile:view 个人中心 user/profile],
]
perm_by_code = rbac_permissions.each_with_object({}) do |(code, name, resource), acc|
  acc[code] = Permission.find_or_create_by!(code: code) do |p|
    p.name = name
    p.resource = resource
  end
end

super_admin_role = Role.find_or_create_by!(code: "super_admin") do |r|
  r.name = "超级管理员"
  r.description = "拥有全部权限（在 ApplicationPolicy 基类短路放行）"
  r.status = :enabled
end

admin_role = Role.find_or_create_by!(code: "admin") do |r|
  r.name = "管理员"
  r.description = "常规管理权限（不含菜单管理）"
  r.status = :enabled
end

# super_admin 绑定全部权限
Permission.pluck(:id).each do |pid|
  RolePermission.find_or_create_by!(role_id: super_admin_role.id, permission_id: pid)
end

# admin 绑定部分权限（演示分权，不含 system:menu:list）
%w[dashboard:view system:manage system:user:list system:role:list system:dept:list
   system:dept:create system:dept:edit system:dept:delete
   monitor:manage monitor:operlog:list monitor:loginlog:list user:profile:view].each do |code|
  perm = perm_by_code[code]
  next unless perm
  RolePermission.find_or_create_by!(role_id: admin_role.id, permission_id: perm.id)
end

# 菜单树（对齐 adminMenu.tsx；用 name 作幂等键，避免目录类 route 为 nil 冲突）
def seed_menu(_key, name, menu_type, opts = {})
  Menu.find_or_create_by!(name: name) do |m|
    m.menu_type = menu_type
    m.route = opts[:route]
    m.permission_code = opts[:permission_code]
    m.icon = opts[:icon]
    m.sort = opts[:sort] || 0
    m.status = opts[:status] || :visible
    m.parent_id = opts[:parent_id]
  end
end

seed_menu("dashboard", "仪表盘", :menu, route: "/admin", permission_code: "dashboard:view", icon: "DashboardOutlined", sort: 1)
sys = seed_menu("system", "系统管理", :catalog, permission_code: "system:manage", icon: "UserOutlined", sort: 2)
seed_menu("users", "用户管理", :menu, route: "/admin/users", permission_code: "system:user:list", icon: "UserOutlined", sort: 1, parent_id: sys.id)
seed_menu("roles", "角色管理", :menu, route: "/admin/roles", permission_code: "system:role:list", icon: "TeamOutlined", sort: 2, parent_id: sys.id)
seed_menu("menus", "菜单管理", :menu, route: "/admin/menus", permission_code: "system:menu:list", icon: "MenuOutlined", sort: 3, parent_id: sys.id)
seed_menu("departments", "部门管理", :menu, route: "/admin/departments", permission_code: "system:dept:list", icon: "ApartmentOutlined", sort: 4, parent_id: sys.id)
mon = seed_menu("monitor", "系统监控", :catalog, permission_code: "monitor:manage", icon: "FileTextOutlined", sort: 3)
seed_menu("operation-logs", "操作日志", :menu, route: "/admin/operation-logs", permission_code: "monitor:operlog:list", icon: "FileTextOutlined", sort: 1, parent_id: mon.id)
seed_menu("login-logs", "登录日志", :menu, route: "/admin/login-logs", permission_code: "monitor:loginlog:list", icon: "HistoryOutlined", sort: 2, parent_id: mon.id)
seed_menu("profile", "个人中心", :menu, route: "/admin/profile", permission_code: "user:profile:view", icon: "IdcardOutlined", sort: 4)
seed_menu("inertia-example", "Inertia 演示", :menu, route: "/admin/inertia-example", icon: "ExperimentOutlined", sort: 5)

# 字典管理（P1 首模块）：目录 + 类型管理 + 数据项管理，对齐 adminMenu.tsx。
rbac_permissions += [
  %w[system:dict:type:list 字典类型管理 system/dict/type],
  %w[system:dict:type:create 字典类型新增 system/dict/type],
  %w[system:dict:type:edit 字典类型编辑 system/dict/type],
  %w[system:dict:type:delete 字典类型删除 system/dict/type],
  %w[system:dict:data:list 字典数据项管理 system/dict/data],
  %w[system:dict:data:create 字典数据项新增 system/dict/data],
  %w[system:dict:data:edit 字典数据项编辑 system/dict/data],
  %w[system:dict:data:delete 字典数据项删除 system/dict/data],
]
# 重新注册新权限码（幂等），确保 Permission 表含字典相关权限点。
rbac_permissions.uniq.each do |(code, name, resource)|
  perm_by_code[code] = Permission.find_or_create_by!(code: code) do |p|
    p.name = name
    p.resource = resource
  end
end
# 新权限点同步授权给 super_admin（全量绑定）。
Permission.pluck(:id).each do |pid|
  RolePermission.find_or_create_by!(role_id: super_admin_role.id, permission_id: pid)
end

dict = seed_menu("dict", "字典管理", :catalog, permission_code: "system:dict:type:list", icon: "BookOutlined", sort: 5, parent_id: sys.id)
seed_menu("dict-types", "类型管理", :menu, route: "/admin/dictionary_types", permission_code: "system:dict:type:list", icon: "BookOutlined", sort: 1, parent_id: dict.id)
seed_menu("dict-data", "数据项管理", :menu, route: "/admin/dictionary_data", permission_code: "system:dict:data:list", icon: "UnorderedListOutlined", sort: 2, parent_id: dict.id)

# 在线用户（P1 第一批末项）：会话监控 + 强制下线。
rbac_permissions += [
  %w[system:online:list 在线用户监控 monitor/online],
  %w[system:online:force 强制下线 monitor/online],
]
rbac_permissions.uniq.each do |(code, name, resource)|
  perm_by_code[code] = Permission.find_or_create_by!(code: code) do |p|
    p.name = name
    p.resource = resource
  end
end
# super_admin 绑定全部权限（含在线用户）。
Permission.pluck(:id).each do |pid|
  RolePermission.find_or_create_by!(role_id: super_admin_role.id, permission_id: pid)
end
# admin 角色也授予在线用户权限（监控 + 强制下线）。
%w[system:online:list system:online:force].each do |code|
  perm = perm_by_code[code]
  next unless perm
  RolePermission.find_or_create_by!(role_id: admin_role.id, permission_id: perm.id)
end
seed_menu("online-users", "在线用户", :menu, route: "/admin/online_users", permission_code: "system:online:list", icon: "LogoutOutlined", sort: 3, parent_id: mon.id)

# 默认 admin 用户绑定超级管理员角色
if (admin_user = User.find_by(username: "admin"))
  UserRole.find_or_create_by!(user_id: admin_user.id, role_id: super_admin_role.id)
end

# ---- 演示数据（仅 development / test 注入：样板，让 用户/角色 列表有真实可浏览数据；幂等可重跑）----
if seeding_demo
  demo_roles = {
    "user"    => ["普通用户", "基础业务权限"],
    "auditor" => ["审计员", "仅查看日志"],
    "ops"     => ["运维", "监控与部署"],
    "finance" => ["财务", "财务相关模块"],
    "guest"   => ["访客", "只读预览"],
  }
  demo_roles.each do |code, (name, desc)|
    Role.find_or_create_by!(code: code) do |r|
      r.name = name
      r.description = desc
      r.status = :enabled
    end
  end

  # 演示角色绑定最小权限（仅仪表盘 + 个人中心，避免越权）
  %w[dashboard:view user:profile:view].each do |pc|
    perm = perm_by_code[pc]
    next unless perm
    demo_roles.each_key do |code|
      role = Role.find_by(code: code)
      next unless role
      RolePermission.find_or_create_by!(role_id: role.id, permission_id: perm.id)
    end
  end

  # 部门树（P1 第二批）：演示部门 + 绑定 demo 用户 department_id。
  dept_hq = Department.find_or_create_by!(name: "总公司") do |d|
    d.code = "HQ"
    d.sort = 0
    d.status = :enabled
  end
  dept_by_name = { "总公司" => dept_hq }
  [
    ["研发部", "RD", 1],
    ["市场部", "MKT", 2],
    ["财务部", "FIN", 3],
    ["人事部", "HR", 4],
    ["运维部", "OPS", 5],
  ].each do |(name, code, sort)|
    dep = Department.find_or_create_by!(name: name) do |d|
      d.code = code
      d.parent = dept_hq
      d.sort = sort
      d.status = :enabled
    end
    dept_by_name[name] = dep
  end

  # 演示用户（dept 字符串映射到真实部门；密码统一 demo123456）
  demo_users = [
    ["wangwu", "研发部", "user", :enabled],
    ["lisi", "市场部", "user", :enabled],
    ["zhaoliu", "财务部", "user", :disabled],
    ["qianqi", "人事部", "user", :enabled],
    ["sunba", "研发部", "user", :enabled],
    ["zhoujiu", "市场部", "user", :disabled],
    ["wushi", "财务部", "user", :enabled],
    ["zhengyi", "研发部", "auditor", :enabled],
    ["yangba", "运维部", "ops", :enabled],
    ["chenqi", "财务部", "finance", :enabled],
    ["huangjiu", "人事部", "guest", :enabled],
    ["xushi", "研发部", "guest", :disabled],
  ]
  demo_users.each_with_index do |(username, _dept, role_code, status), i|
    user = User.find_or_create_by!(username: username) do |u|
      u.email = "#{username}@qingwuxu.dev"
      u.phone = "139#{format('%08d', i + 1)}"
      u.password = "demo123456"
      u.status = status
      u.department = dept_by_name[_dept]
    end
    role = Role.find_by(code: role_code)
    UserRole.find_or_create_by!(user_id: user.id, role_id: role.id) if role
  end

  # 字典联调数据（若依式常用字典）：sys_user_sex 男/女；便于前端字典页联调。
  sex_type = DictionaryType.find_or_create_by!(code: "sys_user_sex") do |t|
    t.name = "用户性别"
    t.status = :enabled
    t.sort = 1
  end
  [
    ["男", "0", 1],
    ["女", "1", 2],
  ].each do |(label, value, sort)|
    DictionaryData.find_or_create_by!(dict_type: sex_type.code, value: value) do |d|
      d.label = label
      d.status = :enabled
      d.sort = sort
    end
  end
else
  Rails.logger.info "生产环境：已跳过 12 个 demo 用户与 5 个 demo 角色，仅保留 RBAC 基础与 super_admin 初始账户。"
end

if seeding_demo
  puts "Seed 完成（演示数据已注入）：admin / 13800000000 / admin123456（用户名 / 手机 / 邮箱 + 密码 均可登录）"
else
  puts "Seed 完成（生产模式：已跳过演示账户，仅创建 super_admin 初始账户；其密码来自 ENV / 凭证）"
end
puts "RBAC 初始化：角色 #{Role.count} · 权限 #{Permission.count} · 菜单 #{Menu.count}"
