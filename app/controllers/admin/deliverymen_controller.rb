class Admin::DeliverymenController < Admin::BaseController

  before_action :set_deliveryman,only:[:edit, :update, :destroy, :show]
  before_filter :authenticate_member!
  
  def index
    @deliverymen = Deliveryman.page(params[:page])
  end

  def new
    @deliveryman = Deliveryman.new
  end

  def create
    @deliveryman = Deliveryman.new(deliveryman_params)
    if @deliveryman.save
      redirect_to admin_deliverymen_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @deliveryman.update(deliveryman_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_deliverymen_path
    else
      render 'edit' 
    end
  end

  def destroy
    @deliveryman.destroy
    redirect_to :back
  end

  def show
    @orders = @deliveryman.orders.where(state: 2).latest
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = Order.chart_data(@orders, @date, @today, select_time, params)
    @order_stats = Order.get_order_stats(@total, @start_time, @end_time)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
    @categories_product_num, @series_product_num, start_time, end_time, @total_product_num, @min_tick_product_num = Order.chart_data_product_num(@orders, @date, @today, select_time, params)
    @chart_product_num = Order.chart_base_line_product_num(@categories_product_num, @series_product_num, @min_tick_product_num) if @categories_product_num.present?
    @categories_push_money, @series_push_money, start_time, end_time, @total_push_money, @min_tick_push_money = Order.chart_data_push_money(@orders, @date, @today, select_time, params)
    @chart_push_money = Order.chart_base_line_push_money(@categories_push_money, @series_push_money, @min_tick_push_money) if @categories_push_money.present?
  end

  private 
    def set_deliveryman
      @deliveryman = Deliveryman.find(params[:id])
    end

    def deliveryman_params
      params.require(:deliveryman).permit(:name, :phone)
    end
end
