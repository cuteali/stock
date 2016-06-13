class Address < ActiveRecord::Base
  belongs_to :user
  has_many :orders, dependent: :destroy

  scope :latest, -> { order('created_at DESC') }
end
