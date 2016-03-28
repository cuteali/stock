class ProductAdmin < ActiveRecord::Base
  belongs_to :product

  scope :latest, -> { order('created_at DESC') }
end
