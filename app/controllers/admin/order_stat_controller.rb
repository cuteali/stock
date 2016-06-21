class Admin::OrderStatController < Admin::BaseController
  def index
    if current_member.spreader?
      user_ids = current_member.promoter.users.pluck(:id)
      @orders = Order.normal_orders.user_orders(user_ids).latest
    else
      @orders = Order.normal_orders.latest
    end
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = Order.chart_data(@orders, @date, @today, select_time, params)
    @order_stats = Order.get_order_stats(@total, @start_time, @end_time)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
    @categories_profit, @series_profit, start_time, end_time, @profit, @min_tick_profit = Order.chart_data_profit(@orders, @date, @today, select_time, params)
    @chart_profit = Order.chart_base_line_profit(@categories_profit, @series_profit, @min_tick_profit) if @categories_profit.present?
  end
end
