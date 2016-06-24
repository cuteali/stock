class Admin::ProductStatController < Admin::BaseController
  def index
    @q = Product.ransack(params[:q])
    product_ids = @q.result.pluck(:id)
    if params[:q] && (params[:q][:category_id_eq] || params[:q][:name_cont])
      @orders_products = OrdersProduct.normal.by_pro_ids(product_ids)
    else
      @orders_products = OrdersProduct.normal
    end
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @start_time, @end_time, @total, @scope_ops = OrdersProduct.chart_data(@orders_products, @date, @today, select_time, params)
    @orders_products_stats = @total.page(params[:page])
  end

  def show
    @order_ids = params[:order_ids]
    @product = Product.find_by(id: params[:id])
    @orders = Order.where(id: @order_ids.split(',')).latest.page(params[:page])
  end
end
