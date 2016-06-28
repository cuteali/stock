class Storehouse < ActiveRecord::Base
  has_many :orders
  
  scope :latest, -> { order('created_at DESC') }
end
