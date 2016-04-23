class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
end
