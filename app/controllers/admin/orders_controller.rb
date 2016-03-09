class Admin::OrdersController < Admin::BaseController
  before_action :set_order,only:[:edit,:update,:destroy,:show]
  def index
    @orders = Order.page(params[:page]).per(20)
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def update
    AppLog.info("params:   #{params[:order][:complete_time]}")
    if @order.update(order_params)
      AppLog.info("order.complete_time  #{@order.id}")
      redirect_to admin_orders_path
    else
      render 'edit' 
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path
  end

  def create
    @order = Order.new(order_params)
    @order.unique_id = SecureRandom.urlsafe_base64
    if @order.save
      redirect_to admin_orders_path
    else
      render 'new'
    end
  end

  def show
    @products = JSON.parse(@order.products)
  end

  private 
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:state,:phone_num,:receive_name,:delivery_time,:address_id,:complete_time,:user_id)
    end
end