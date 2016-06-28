class Admin::StorehousesController < Admin::BaseController
  before_action :set_storehouse,only:[:edit, :update, :destroy, :show]
  before_filter :authenticate_member!

  def index
    @storehouses = Storehouse.page(params[:page])
  end

  def new
    @storehouse = Storehouse.new
    render :form
  end

  def create
    @storehouse = Storehouse.new(storehouse_params)
    if @storehouse.save
      redirect_to admin_storehouses_path
    else
      flash[:alert] = '新建失败'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @storehouse.update(storehouse_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_storehouses_path
    else
      flash[:alert] = '修改失败'
      redirect_to :back
    end
  end

  def destroy
    @storehouse.destroy
    redirect_to :back
  end

  def show
    @orders = @storehouse.orders.normal_orders.latest
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
  end

  private 
    def set_storehouse
      @storehouse = Storehouse.find(params[:id])
    end

    def storehouse_params
      params.require(:storehouse).permit(:name, :detail)
    end
end
