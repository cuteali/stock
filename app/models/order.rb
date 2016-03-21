class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :user

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

  def self.update_order_money(products)
    order_money = 0
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      order_money += product.price * p['number'].to_i
    end
    order_money
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
