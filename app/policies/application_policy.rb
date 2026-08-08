# frozen_string_literal: true

# RBAC 授权策略基类（ActionPolicy 0.7）
# 原则（与 MEMORY 红线一致）：
# - 服务端为唯一真相；最小授权单元是「权限点 permission.code」，绝不硬编码 role。
# - 超管在基类短路放行（与 User#super_admin 一致）。
# - 具体策略只声明「某操作需要哪个权限点」，由 user.has_permission? 统一判定。
class ApplicationPolicy
  include ActionPolicy::Policy::Core
  include ActionPolicy::Policy::Scoping

  # ActionPolicy 0.7 的 policy_for 以 `user:` 关键字注入当前用户
  # （来源：railtie 配置的 `authorize :user, through: :current_user`）
  def initialize(record, user: nil, **)
    @record = record
    @user = user
  end

  def user
    @user
  end

  # 默认拒绝（非超管且无具体规则时）
  def manage?
    false
  end

  # 超管短路：覆盖所有 allow! 调用（controller authorize! 实际走 allow!），任何策略对超管均放行
  def allow!(rule = :manage?, **opts)
    return true if user&.super_admin?
    super
  end

  # ---- 默认作用域（IDOR 防线，前瞻落地）----
  # ActionPolicy 的 scope 机制：类型 :active_record_relation 由 rails 启动时
  # 经 ActiveSupport.on_load(:active_record) 注册（见 action_policy rails 适配）。
  # 控制器侧用 authorized_scope(User.all, with: UserPolicy)（本项目别名 policy_scope）包装查询，
  # 使未来 show/update/destroy 等写操作天然受 scope 约束。
  #   - 超管：直通全量。
  #   - 普通用户：按 required_scope_permission 判定；无对应权限点返回空集（拒绝越权读取）。
  scope_for :active_record_relation do |relation|
    next relation if user&.super_admin?

    required = required_scope_permission
    next relation.none unless required && user&.has_permission?(required)

    # ---- 数据权限：仅对含 department_id 列的资源按部门过滤 ----
    # 无该列（如 Role/Department/Permission）一律返回原 relation，不破坏既有 IDOR 防线。
    next relation unless relation.respond_to?(:klass) &&
                         relation.klass.column_names.include?("department_id")

    # 未设置范围或「全部」：放行（已通过 required_scope_permission 校验）。
    next relation if user&.data_scope.nil? || user.data_scope.to_sym == :all

    case user.data_scope.to_sym
    when :dept
      # 本部门：仅当前用户所属部门
      relation.where(department_id: user.department_id)
    when :dept_and_child
      # 本部门及下级：包含祖先路径命中当前部门的全部子树节点
      child_ids = Department.where("ancestors LIKE ? OR id = ?",
                                   "%#{user.department_id}%", user.department_id).pluck(:id)
      relation.where(department_id: [user.department_id, *child_ids])
    when :self
      # 仅自己
      relation.where(id: user.id)
    else
      # custom 等其他范围暂按全部处理（自定义名单为后续分期）
      relation
    end
  end

  # 子类覆盖：声明该资源列表/读取所需的权限点（最小授权单元 permission.code）。
  # 默认 nil → 普通用户一律拒绝（空集），符合「默认最小化」原则。
  def required_scope_permission
    nil
  end

  # 注册 :active_record_relation 作用域类型匹配。该匹配默认由 action_policy 的 rails 适配
  # 挂在 ActionPolicy::Base 上；本项目 ApplicationPolicy 不继承 Base（仅 include Core + Scoping），
  # 故在此显式注册，使 authorized_scope / policy_scope 能自动推断 Relation 的 scope 类型。
  scope_matcher :active_record_relation, ActiveRecord::Relation
end
