# frozen_string_literal: true

# 菜单：树形结构，自引用 parent_id。
# menu_type 避开 Rails STI 保留字 type（0=目录 1=菜单 2=按钮）。
class Menu < ApplicationRecord
  belongs_to :parent, class_name: "Menu", optional: true
  has_many :children, -> { order(sort: :asc) },
           class_name: "Menu", foreign_key: :parent_id, dependent: :destroy

  enum :menu_type, { catalog: 0, menu: 1, button: 2 }, default: :menu
  enum :status, { hidden: 0, visible: 1 }, default: :visible

  validates :name, presence: true
end
