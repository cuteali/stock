class Category < ActiveRecord::Base
  has_many :sub_categories
  has_many :detail_categories
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :images, as: :target, dependent: :destroy

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  def self.init_sort
    Category.maximum(:sort) + 1
  end
end
