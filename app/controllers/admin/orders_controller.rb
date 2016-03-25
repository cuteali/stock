class Admin::OrdersController < Admin::BaseController
  before_action :set_order,only:[:edit,:update,:destroy,:show]
  
  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result.latest.page(params[:page]).per(10)
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def update
    AppLog.info("params:   #{params[:order][:complete_time]}")
    @order.restore_products
    if @order.update(order_params)
      Product.edit_stock_num(JSON.parse(@order.products))
      AppLog.info("order.complete_time  #{@order.id}")
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_orders_path
    else
      render 'edit' 
    end
  end

  def destroy
    @order.restore_products
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
      params.require(:order).permit(:state, :phone_num, :receive_name, :delivery_time, :address_id, :complete_time, :user_id).tap do |whitelisted|
        whitelisted[:products] = params[:order][:products].to_json
        whitelisted[:order_money] = Order.update_order_money(params[:order][:products])
      end
    end
end
