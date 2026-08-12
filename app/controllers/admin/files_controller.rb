# frozen_string_literal: true

module Admin
  # 文件管理（P1-D）：本地磁盘 Active Storage 文件服务。
  # - 列表（index）：展示已上传文件（预览 / 下载 / 删除）。
  # - 上传（create）：Inertia 多部件表单（file 参数），成功 redirect，校验失败 422 + errors。
  # - 删除（destroy）：purge blob + 删宿主记录。
  # 安全：authorize! 三态权限点；操作日志由 BaseController 自动记录（登录态写操作）。
  class FilesController < BaseController
    before_action :set_file, only: [:destroy]

    def index
      authorize! UploadedFile, to: :list?, with: FilePolicy
      render inertia: "admin/files/index", props: files_props
    end

    def create
      authorize! UploadedFile, to: :upload?, with: FilePolicy
      uploaded = UploadedFile.new
      uploaded.file.attach(params[:file])
      if uploaded.save
        redirect_to admin_files_path
      else
        render inertia: "admin/files/index",
               props: files_props.merge(errors: uploaded.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! @uploaded_file, to: :delete?, with: FilePolicy
      @uploaded_file.file.purge
      @uploaded_file.destroy
      redirect_to admin_files_path
    end

    private

    def set_file
      @uploaded_file = UploadedFile.find(params[:id])
    end

    def files_props
      {
        files: UploadedFile.includes(file_attachment: :blob).order(created_at: :desc).filter_map do |f|
          attachment = f.file
          next unless attachment.attached?

          {
            id: f.id,
            filename: attachment.filename.to_s,
            content_type: attachment.content_type,
            byte_size: attachment.byte_size,
            created_at: attachment.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            preview_url: blob_url(attachment, :inline),
            download_url: blob_url(attachment, :attachment)
          }
        end
      }
    end

    # Active Storage 重定向路由（/rails/active_storage/blobs/redirect/...），
    # 浏览器直接打开预览或下载；disposition 控制 inline（预览）/ attachment（下载）。
    # only_path: true 产出相对路径，前端 <a href> 即可，不依赖请求 host。
    def blob_url(attachment, disposition)
      Rails.application.routes.url_helpers.rails_blob_path(
        attachment.blob, disposition: disposition, only_path: true
      )
    end
  end
end
