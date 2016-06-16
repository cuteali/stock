class Admin::OrdersController < Admin::BaseController
  include Admin::OrderHelper
  include Admin::CategoryHelper

  before_action :set_order, only: [:edit, :update, :destroy, :show, :add_order_product]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    if current_member.spreader?
      user_ids = current_member.promoter.users.pluck(:id)
      @q = Order.user_orders(user_ids).ransack(params[:q])
    else
      @q = Order.ransack(params[:q])
    end
    @orders = @q.result.latest.page(params[:page])
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
      @order.update_order_money
      is_bad_order = edit_disabled(@order.state)
      @order.update_product_stock_num if !is_bad_order
      status = is_bad_order ? 'deleted' : 'normal'
      @order.change_orders_products_status(status)
      @order.order_push_message
      AppLog.info("order.complete_time  #{@order.id}")
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_orders_path
    else
      render 'edit' 
    end
  end

  def destroy
    authorize @order
    @order.restore_products
    @order.destroy
    redirect_to :back
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
    @products = @order.products.group_by(&:category_id)
  end

  def delete_order_product
    order_product = OrdersProduct.find(params[:id])
    order_product.product.restore_stock_num(order_product.product_num) if order_product.product
    order_product.destroy
    redirect_to :back
  end

  def add_order_product
    product = Product.find(params[:product_id])
    orders_product = @order.orders_products.new(product_id: product.id, product_num: params[:product_num], product_price: params[:product_price])
    if params[:product_num].to_i > product.stock_num
      flash[:alert] = "保存失败，产品库存不足"
      render js: 'location.reload()'
    elsif orders_product.save
      @order.update_order_money
      orders_product.product.add_sale_count(orders_product.product_num)
      flash[:notice] = "保存成功"
      render js: 'location.reload()'
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def select_product
    product = Product.find_by(id: params[:product_id])
    html = get_select_product_html(product)
    render json: {html: html, product_id: product.id}
  end

  def search_product
    options = Product.where("name like ?", "%#{params[:product_name]}%").sorted
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  private 
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:state, :phone_num, :receive_name, :delivery_time, :area, :detail, :complete_time, :user_id, :remarks, orders_products_attributes: [:id, :product_num, :product_price])
    end
end
