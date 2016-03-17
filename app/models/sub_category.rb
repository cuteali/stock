class SubCategory < ActiveRecord::Base
  belongs_to :category
  has_many :adverts
  has_many :detail_categories
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  def self.init_sort
    SubCategory.maximum(:sort) + 1
  end
end
