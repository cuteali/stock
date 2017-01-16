class Admin::MergeOrdersController < Admin::BaseController
  before_action :set_merge_order, only: [:destroy, :show]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    if current_member.admin?
      @q = MergeOrder.ransack(params[:q])
    else
      @q = current_member.merge_orders.ransack(params[:q])
    end
    @merge_orders = @q.result.latest.page(params[:page])
  end

  def new
    @merge_order = current_member.merge_orders.new
  end

  def create
    return redirect_to :back, alert: '请输入订单号' if params[:order_nos].blank?
    order_nos = params[:order_nos].split(' ')
    repeated_order_nos = order_nos.select{|e| order_nos.count(e) > 1 }.uniq
    return redirect_to :back, alert: "订单号：#{repeated_order_nos.join(', ')}重复" if repeated_order_nos.present?
    new_merge_orders_orders(order_nos)
    return redirect_to :back, alert: "订单号：#{@error_order_nos.join(', ')}未找到" if @error_order_nos.present?
    @merge_order = current_member.merge_orders.new(unique_id: SecureRandom.urlsafe_base64)
    if @merge_order.save
      @merge_order.save_merge_orders_orders(@merge_orders_orders)
      redirect_to admin_merge_orders_path
    else
      render 'new'
    end
  end

  def destroy
    authorize @merge_order
    @merge_order.destroy
    redirect_to :back
  end


  def show
    @products = @merge_order.products.group_by(&:category_id)
  end

  private 
    def set_merge_order
      @merge_order = MergeOrder.find(params[:id])
    end

    def new_merge_orders_orders(order_nos)
      @merge_orders_orders = []
      @error_order_nos = []
      order_nos.each do |order_no|
        order = Order.find_by(order_no: order_no)
        if order
          @merge_orders_orders << order.merge_orders_orders.new
        else
          @error_order_nos << order_no
        end
      end
    end
end
