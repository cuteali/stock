class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :user
  has_many :orders_products, dependent: :destroy
  has_many :products, through: :orders_products
  accepts_nested_attributes_for :orders_products, allow_destroy: true

  validates :order_no, uniqueness: true

  before_create :generate_order_no

  scope :latest, -> { order('created_at DESC') }

  def get_address
    address = self.address
    if address.present?
      address.area.to_s + address.detail.to_s
    else
      ""
    end
  end

  def self.check_order_money(products)
    order_money = 0
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      order_money += product.price * p['number'].to_i
    end
    order_money
  end

  def update_order_money
    new_order_money = orders_products.to_a.sum do |op|
      op.product.price * op.product_num
    end
    self.update(order_money: new_order_money)
  end

  def restore_products
    orders_products.each do |op|
      op.product.restore_stock_num(op.product_num)
    end
  end

  def create_orders_products(products)
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      self.orders_products.where(product_id: product.try(:id), product_num: p['number']).first_or_create
    end
  end

  def update_product_stock_num
    pro_ids = []
    orders_products.each do |op|
      if op.product.stock_num >= op.product_num
        pro_ids << op.product_id
        op.product.stock_num -= op.product_num
        op.product.sale_count += op.product_num
        op.product.save
      else
        break
      end
    end
    pro_ids
  end

  def validate_product_stock_num
    result = 0
    orders_products.each do |op|
      if op.product.stock_num < op.product_num
        result = 3
        break
      end
    end
    result
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
