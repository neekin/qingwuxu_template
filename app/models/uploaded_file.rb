# frozen_string_literal: true

# 文件管理（P1-D）：本地磁盘 Active Storage 宿主模型。
# 仅作文件记录的「宿主」，文件本体存于 Active Storage（storage/ 磁盘），
# 元数据（文件名 / 类型 / 大小）来自所属 blob。无需额外业务列。
# 注：当前 Active Storage 版本未注册 attached/size 校验器，故手写校验避免 Unknown validator。
class UploadedFile < ApplicationRecord
  has_one_attached :file

  validate :file_must_be_attached, :file_size_within_limit

  MAX_SIZE = 50.megabytes

  private

  def file_must_be_attached
    errors.add(:file, "请选择要上传的文件") unless file.attached?
  end

  def file_size_within_limit
    return unless file.attached?

    if file.byte_size > MAX_SIZE
      errors.add(:file, "文件不得超过 #{MAX_SIZE / 1.megabyte}MB")
    end
  end
end
