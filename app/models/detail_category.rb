class DetailCategory < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :images, as: :target

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  def self.init_sort
    DetailCategory.maximum(:sort) + 1
  end
end
