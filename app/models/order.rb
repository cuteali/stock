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

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
