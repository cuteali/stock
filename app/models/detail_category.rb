class DetailCategory < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :images, as: :target, dependent: :destroy

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  def self.init_sort
    DetailCategory.maximum(:sort) + 1
  end

  def validate_category_id_and_sub_category_id(params)
    if category_id != params[:category_id].to_i
      products.update_all(category_id: params[:category_id])
    end
    if sub_category_id != params[:sub_category_id].to_i
      products.update_all(sub_category_id: params[:sub_category_id])
    end
  end
end
