class MergeOrdersOrder < ActiveRecord::Base
  belongs_to :merge_order
  belongs_to :order

  def create_merge_order_products
    order.orders_products.each do |op|
      merge_orders_product = op.product.merge_orders_products.where(merge_order_id: merge_order.id).first_or_initialize
      merge_orders_product.product_num = merge_orders_product.product_num.to_i + op.product_num
      merge_orders_product.save
    end
  end
end
