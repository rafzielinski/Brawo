class ContentType < ApplicationRecord
  has_many :contents
  validates :name, presence: true, uniqueness: true
  validates :fields, presence: true

  def field_definitions
    JSON.parse(fields) rescue []
  end

  def field_definitions=(value)
    self.fields = value.to_json
  end
end
