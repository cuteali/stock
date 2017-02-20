class Address < ActiveRecord::Base
  belongs_to :user
  has_many :orders

  scope :latest, -> { order('created_at DESC') }
end
