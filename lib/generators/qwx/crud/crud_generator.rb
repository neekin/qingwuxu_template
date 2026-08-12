# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Qwx
  # 全栈 CRUD 代码生成器。
  #
  #   bin/rails g qwx:crud Article title:string body:text published:boolean category:references
  #
  # 产出与手写范式 100% 一致的：迁移 + 模型 + Admin 控制器（写路径）+ ActionPolicy（三态权限点）
  # + Inertia 页面（ProListPage）+ 三态控制器测试。
  # routes / seeds / adminMenu 仅打印片段（不自动改既有文件），由开发者粘贴。
  #
  # 字段类型 → 前端控件映射：
  #   string   → ProFormText      text     → ProFormTextArea
  #   integer/decimal/float → ProFormDigit
  #   boolean  → ProFormSwitch    datetime/date → ProFormDateTimePicker
  #   references → ProFormSelect（值走 <name>_id，选项来源 all_<name>s）
  class CrudGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("templates", __dir__)

    # 将 name 之后的位置参数解析为 attributes 数组（Rails 8 NamedBase 需显式声明）。
    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    class_option :department, type: :boolean, default: true,
                 desc: "生成数据权限列 department_id（默认开启；--no-department 关闭）"

    # 唯一公开 action：生成全部文件并打印手动粘贴片段。
    def copy_templates
      # 显式时间戳命名迁移（避免依赖 migration_template 的版本差异）。
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      template "migration.rb.tt", File.join("db/migrate", "#{timestamp}_create_#{table_name}.rb")

      template "model.rb.tt", File.join("app/models", "#{file_name}.rb")
      template "controller.rb.tt", File.join("app/controllers/admin", "#{controller_file_name}_controller.rb")
      template "policy.rb.tt", File.join("app/policies", "#{file_name}_policy.rb")
      template "frontend_page.tsx.tt", File.join("app/frontend/pages/admin/#{table_name}", "index.tsx")
      template "controller_test.rb.tt",
               File.join("test/controllers/admin", "#{controller_file_name}_controller_test.rb")

      print_manual_snippets
    end

    private

    # ---- 供模板复用的辅助方法（private，避免被当作 generator action 执行）----

    # 权限点前缀：system:<资源名单数>  →  system:article
    def permission_prefix
      "system:#{file_name}"
    end

    # 是否生成数据权限列
    def with_department?
      options[:department]
    end

    # 引用类字段（references/belongs_to）
    def reference_attributes
      attributes.select(&:reference?)
    end

    # 引用选项/展示用的标签列：优先 name，其次 username（如 User），再退化 id。
    # 生成器在 Rails 上下文内可加载被引用模型，按真实列解析，避免硬编码 name 导致 NoMethodError。
    def reference_label_column(attr)
      klass = attr.name.to_s.camelize.constantize
      if klass.column_names.include?("name")
        "name"
      elsif klass.column_names.include?("username")
        "username"
      else
        "id"
      end
    rescue StandardError
      "name"
    end

    # 非引用、非 department 的普通字段（用于测试样例参数）
    def scalar_attributes
      attributes.reject(&:reference?)
    end

    # 前端 TS 类型映射
    def ts_type(attr)
      case attr.type
      when :boolean then "boolean"
      when :integer, :decimal, :float then "number"
      when :references, :belongs_to then "number"
      else "string"
      end
    end

    # 人类可读标签（驼峰/下划线转空格，保留原大小写；开发者可改中文）
    def human(name)
      name.to_s.gsub(/([a-z\d])([A-Z])/, '\1 \2').tr("_", " ").strip
    end

    # 模板里用到的 ProForm 组件集合（按需 import，避免 tsc noUnusedLocals 报未用）
    def used_pro_form_components
      used = []
      attributes.each do |attr|
        used << case attr.type
                when :text then "ProFormTextArea"
                when :boolean then "ProFormSwitch"
                when :integer, :decimal, :float then "ProFormDigit"
                when :datetime, :date then "ProFormDateTimePicker"
                when :references, :belongs_to then "ProFormSelect"
                else "ProFormText"
                end
      end
      used << "ProFormSelect" if with_department?
      used.uniq
    end

    # 控制器强参数允许列表（含引用 _id 与 department_id）
    def permitted_params
      list = attributes.reject(&:reference?).map { |a| ":#{a.name}" }
      reference_attributes.each { |a| list << ":#{a.name}_id" }
      list << ":department_id" if with_department?
      list.join(", ")
    end

    # 测试样例参数（多行，10 空格缩进，用于 post/patch params 块）
    def sample_params
      scalar_attributes.map do |a|
        val = case a.type
              when :boolean then "true"
              when :integer, :decimal, :float then "1"
              when :datetime, :date then '"2026-01-01 00:00:00"'
              when :text then '"sample content"'
              else '"sample"'
              end
        "          #{a.name}: #{val}"
      end.join(",\n")
    end

    # 测试样例参数（单行，用于 setup 的 create!）
    def sample_params_inline
      scalar_attributes.map do |a|
        val = case a.type
              when :boolean then "true"
              when :integer, :decimal, :float then "1"
              when :datetime, :date then '"2026-01-01 00:00:00"'
              when :text then '"sample content"'
              else '"sample"'
              end
        "#{a.name}: #{val}"
      end.join(", ")
    end

    # 打印需手动粘贴的 routes / seeds / adminMenu 片段（不自动改既有文件）
    def print_manual_snippets
      say ""
      say "✏️  以下片段需手动粘贴（生成器不自动改 routes.rb / seeds.rb / adminMenu.tsx）：", :green
      say ""
      say "1) config/routes.rb —— 放入 namespace :admin do ... end 内：", :yellow
      say "    resources :#{table_name}, only: [:index, :create, :update, :destroy]", :cyan
      say ""
      say "2) db/seeds.rb —— 权限点（super_admin 自动拥有；普通角色按需绑定）：", :yellow
      say "    %w[#{permission_prefix}:list #{permission_prefix}:create #{permission_prefix}:edit #{permission_prefix}:delete].each do |code|", :cyan
      say "      Permission.find_or_create_by!(code: code)", :cyan
      say "    end", :cyan
      say "    Menu.find_or_create_by!(permission_code: '#{permission_prefix}:list') do |m|", :cyan
      say "      m.name = '#{human(class_name)}管理'; m.route = '/admin/#{table_name}'; m.menu_type = 1; m.status = 1; m.sort = 10", :cyan
      say "    end", :cyan
      say ""
      say "3) app/frontend/config/adminMenu.tsx —— 菜单项（挂系统管理目录）：", :yellow
      say "      { key: '#{table_name}', label: '#{human(class_name)}管理', icon: <FileOutlined />, path: '/admin/#{table_name}', permission: '#{permission_prefix}:list' },", :cyan
      say ""
    end
  end
end
