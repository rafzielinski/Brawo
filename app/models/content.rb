class Content < ApplicationRecord
  belongs_to :content_type
  has_many :content_categories
  has_many :categories, through: :content_categories
  has_many :content_tags
  has_many :tags, through: :content_tags
  validates :content_type, presence: true

  def data_hash
    JSON.parse(data) rescue {}
  end

  def data_hash=(value)
    self.data = value.to_json
  end

  def get_field(name)
    data_hash[name]
  end

  def set_field(name, value)
    hash = data_hash
    hash[name] = value
    self.data_hash = hash
  end
end
