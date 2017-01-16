class MergeOrdersProduct < ActiveRecord::Base
  belongs_to :merge_order
  belongs_to :product
end
