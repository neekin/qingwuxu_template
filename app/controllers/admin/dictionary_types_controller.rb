# frozen_string_literal: true

module Admin
  # 字典类型管理（真实写路径：create/update/destroy 走 Inertia POST/PUT/DELETE）。
  # 后端范式：成功 → redirect_to index（Inertia 客户端自动跟随 GET 刷新列表）；
  #          校验失败 → render inertia: 同页 + errors，返回 422（前端 ModalForm 保持打开）。
  class DictionaryTypesController < BaseController
    def index
      authorize! DictionaryType, to: :index?
      render inertia: "admin/dictionary_types/index", props: dictionary_types_props
    end

    def create
      authorize! DictionaryType, to: :create?
      type = DictionaryType.new(dictionary_type_params)
      if type.save
        redirect_to admin_dictionary_types_path
      else
        render inertia: "admin/dictionary_types/index",
               props: dictionary_types_props.merge(errors: type.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! DictionaryType, to: :update?
      type = scoped.find(params[:id])
      if type.update(dictionary_type_params)
        redirect_to admin_dictionary_types_path
      else
        render inertia: "admin/dictionary_types/index",
               props: dictionary_types_props.merge(errors: type.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! DictionaryType, to: :destroy?
      scoped.find(params[:id]).destroy
      redirect_to admin_dictionary_types_path
    end

    private

    # IDOR 防线：列表/写操作都过 policy_scope（超管全量 / 普通按权限过滤）。
    def scoped
      policy_scope(DictionaryType.all, with: DictionaryTypePolicy)
    end

    def dictionary_types_props
      {
        dictionary_types: scoped.order(sort: :asc, created_at: :desc).map do |t|
          {
            id: t.id,
            code: t.code,
            name: t.name,
            status: t.status,
            remark: t.remark,
            sort: t.sort,
            created_at: t.created_at.strftime("%Y-%m-%d %H:%M")
          }
        end
      }
    end

    def dictionary_type_params
      params.require(:dictionary_type).permit(:code, :name, :status, :remark, :sort)
    end
  end
end
