# frozen_string_literal: true

# 字典类型（若依式：不建外键，数据项按 dict_type 字符串关联）。
class DictionaryType < ApplicationRecord
  enum :status, { disabled: 0, enabled: 1 }, default: :enabled

  has_many :dictionary_data,
           class_name: "DictionaryData",
           foreign_key: :dict_type,
           primary_key: :code,
           dependent: :destroy

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :sort, numericality: { only_integer: true }, allow_nil: true

  before_validation :normalize_code

  private

  def normalize_code
    self.code = code.to_s.strip if code.present?
  end
end
