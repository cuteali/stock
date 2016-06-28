class Deliveryman < ActiveRecord::Base
  has_many :orders
end
