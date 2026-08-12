# frozen_string_literal: true

# 文件管理（P1-D）：本地磁盘 Active Storage 宿主表。
# 仅作文件记录的「宿主」，文件本体存于 Active Storage（storage/ 磁盘），
# 元数据（文件名 / 类型 / 大小）来自所属 blob，无需额外业务列。
class CreateUploadedFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :uploaded_files do |t|
      t.timestamps
    end
  end
end
