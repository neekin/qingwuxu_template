# frozen_string_literal: true

# 字典数据项（若依式：按 dict_type 字符串关联类型，不强制 belong_to）。
class DictionaryData < ApplicationRecord
  enum :status, { disabled: 0, enabled: 1 }, default: :enabled

  validates :dict_type, presence: true
  validates :label, presence: true
  validates :value, presence: true
  validates :sort, numericality: { only_integer: true }, allow_nil: true

  # 轻校验：dict_type 必须存在于 dictionary_types 表（若依风格，可选一致性）。
  validate :dict_type_must_exist

  scope :by_type, ->(code) { where(dict_type: code) if code.present? }

  private

  def dict_type_must_exist
    return if dict_type.blank?
    return if DictionaryType.exists?(code: dict_type)
    errors.add(:dict_type, "对应的字典类型不存在")
  end
end
