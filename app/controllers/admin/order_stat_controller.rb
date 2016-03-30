class Admin::OrderStatController < Admin::BaseController
  def index
    @orders = Order.latest
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @order_stats = @orders.one_weeks(@today).select('date(created_at) as created_date, count(*) as count, sum(order_money) as money').group('date(created_at)').order("created_at asc")
    @categories, @series, @start_time, @end_time, @count, @min_tick = Order.chart_data(@orders, @date, @today, select_time, params)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
  end
end
