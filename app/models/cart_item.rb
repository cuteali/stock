class CartItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  def self.product_sold_off(product_id)
    CartItem.where(product_id: product_id).destroy_all
  end

  def self.create_items_restricting(cart_item, user, product, product_num)
    is_restricting = false
    if product.try(:restricting_num).present?
      op = CartItem.get_orders_product(user, product)
      new_num = cart_item.try(:product_num).to_i + product_num.to_i
      new_op_num = op.try(:product_num).to_i + new_num
      is_restricting = CartItem.get_is_restricting(new_op_num, product)
    end
    is_restricting
  end

  def self.edit_items_restricting(user, product, product_num)
    is_restricting = false
    if product.try(:restricting_num).present?
      op = CartItem.get_orders_product(user, product)
      new_op_num = op.try(:product_num).to_i + product_num.to_i
      is_restricting = CartItem.get_is_restricting(new_op_num, product)
    end
    is_restricting
  end

  def self.again_items_restricting(cart_item, user, orders_product)
    is_restricting = false
    if orders_product.product.try(:restricting_num).present?
      op = CartItem.get_orders_product(user, orders_product.product)
      new_num = cart_item.try(:product_num).to_i + orders_product.product_num.to_i
      new_op_num = op.try(:product_num).to_i + new_num
      is_restricting = CartItem.get_is_restricting(new_op_num, orders_product.product)
    end
    is_restricting
  end

  def self.get_is_restricting(new_op_num, product)
    new_op_num > product.restricting_num
  end

  def self.get_orders_product(user, product)
    user.orders_products.where("product_id = ? and DATE(created_at) = ?", product.id, Date.today).first
  end

  def self.total_product_num(user)
    user.cart_items.joins(:product).sum(:product_num)
  end
end
