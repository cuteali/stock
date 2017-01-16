class MergeOrder < ActiveRecord::Base
  belongs_to :member
  has_many :merge_orders_orders, dependent: :destroy
  has_many :orders, through: :merge_orders_orders
  has_many :merge_orders_products, dependent: :destroy
  has_many :products, through: :merge_orders_products

  validates :merge_order_no, uniqueness: true

  scope :latest, -> { order('created_at DESC') }

  before_create :generate_merge_order_no

  def save_merge_orders_orders(merge_orders_orders)
    merge_orders_orders.each do |merge_orders_order|
      merge_orders_order.merge_order = self
      merge_orders_order.save
      merge_orders_order.create_merge_order_products
    end
  end

  private
    def generate_merge_order_no
      max_merge_order_no = MergeOrder.maximum(:merge_order_no) || 201701160
      self.merge_order_no = max_merge_order_no.succ
    end
end
