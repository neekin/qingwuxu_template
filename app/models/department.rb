# frozen_string_literal: true

# 部门（树形，自引用）。
# - parent / children：自引用树形关系。
# - ancestors：逗号分隔的祖先 id 路径（如 "1,3"），便于「含下级」查询，由 before_save 维护。
# - 平铺列表由控制器注入 parent 名称；树形可经 children 递归构建。
class Department < ApplicationRecord
  belongs_to :parent, class_name: "Department", foreign_key: :parent_id, optional: true
  has_many :children, class_name: "Department", foreign_key: :parent_id, dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :sort, numericality: { only_integer: true }, allow_nil: true
  validate :parent_not_self

  before_save :maintain_ancestors

  scope :tree, -> { order(sort: :asc, id: :asc) }
  scope :roots, -> { where(parent_id: nil) }

  private

  # 禁止将自身设为自己的上级（环检测第一道）。
  def parent_not_self
    return if parent_id.blank?
    errors.add(:parent_id, "不能选择自身为上级") if parent_id == id
  end

  # 维护 ancestors：parent 为 nil → nil；否则 parent.ancestors + parent.id，逗号分隔。
  def maintain_ancestors
    self.ancestors = if parent_id.blank?
      nil
    else
      parent = Department.find_by(id: parent_id)
      parent ? [parent.ancestors, parent.id].compact.join(",") : nil
    end
  end
end
