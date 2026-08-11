# frozen_string_literal: true

module Admin
  # 字典数据项管理（真实写路径；index 支持按 dict_type 过滤；写操作校验 dict_type 存在）。
  class DictionaryDataController < BaseController
    def index
      authorize! DictionaryData, to: :index?
      render inertia: "admin/dictionary_data/index", props: dictionary_data_props
    end

    def create
      authorize! DictionaryData, to: :create?
      item = DictionaryData.new(dictionary_data_params)
      if item.save
        redirect_to admin_dictionary_data_path(dict_type: item.dict_type)
      else
        render inertia: "admin/dictionary_data/index",
               props: dictionary_data_props.merge(errors: item.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! DictionaryData, to: :update?
      item = scoped.find(params[:id])
      if item.update(dictionary_data_params)
        redirect_to admin_dictionary_data_path(dict_type: item.dict_type)
      else
        render inertia: "admin/dictionary_data/index",
               props: dictionary_data_props.merge(errors: item.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! DictionaryData, to: :destroy?
      item = scoped.find(params[:id])
      dict_type = item.dict_type
      item.destroy
      redirect_to admin_dictionary_data_path(dict_type: dict_type)
    end

    private

    # IDOR 防线：列表/写操作都过 policy_scope。
    def scoped
      policy_scope(DictionaryData.all, with: DictionaryDataPolicy)
    end

    # index 按 dict_type 过滤（query param），无参数则全量（受 scope 约束）。
    def dictionary_data_props
      rel = scoped
      rel = rel.where(dict_type: params[:dict_type]) if params[:dict_type].present?
      {
        dict_type: params[:dict_type],
        dictionary_data: rel.order(sort: :asc, created_at: :desc).map do |d|
          {
            id: d.id,
            dict_type: d.dict_type,
            label: d.label,
            value: d.value,
            status: d.status,
            remark: d.remark,
            sort: d.sort,
            created_at: d.created_at.strftime("%Y-%m-%d %H:%M")
          }
        end
      }
    end

    # 前端 ProListPage 发裸 values（无 :dictionary_data 包裹），用 permit 直接收。
    def dictionary_data_params
      params.permit(:dict_type, :label, :value, :status, :remark, :sort)
    end
  end
end
