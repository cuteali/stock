class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :user
  belongs_to :deliveryman
  belongs_to :car
  belongs_to :storehouse
  has_many :messages, as: :messageable
  has_many :orders_products, dependent: :destroy
  has_many :products, through: :orders_products
  accepts_nested_attributes_for :orders_products, allow_destroy: true

  validates :order_no, uniqueness: true

  before_create :generate_order_no

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :user_orders, ->(ids) { where(user_id: ids) }
  scope :one_days, ->(today) { where("date(created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :normal_orders, -> { where(state: [0, 1, 2, 4, 5]) }
  scope :by_state, ->(state_arr) { 
    if state_arr.include?(2)
      where(state: 2)
    else
      where(state: [0, 1, 4, 5])
    end
  }

  scope :by_new_state, ->(state) { 
    case state
    when '0' then where(state: [0, 1, 2, 3, 4, 5])
    when '1' then where(state: 0)
    when '2' then where(state: [1, 4, 5])
    when '3' then where(state: 2)
    when '4' then where(state: 3)
    end
  }

  def update_product_cost_price(orders_products_attributes)
    orders_products_attributes.each do |attrs|
      op = OrdersProduct.find_by(id: attrs[:id])
      if op.cost_price != attrs[:cost_price].to_f
        op.product.update_columns(cost_price: attrs[:cost_price].to_f)
        OrdersProduct.joins(:order).one_days(Date.today).where("orders.state in (?) and orders_products.product_id = ? and orders_products.id != ?", [0, 1, 4, 5], op.product_id, op.id).each do |today_op|
          today_op.update_columns(cost_price: attrs[:cost_price].to_f)
          today_op.order.calculate_cost_price
        end
      end
    end
  end

  def calculate_cost_price
    new_total_cost_price = orders_products.to_a.sum do |op|
      (op.product_price.to_f - op.cost_price.to_f) * op.product_num.to_i
    end
    self.update_columns(total_cost_price: new_total_cost_price)
  end

  def state_return_value
    if state == 0
      '1'
    elsif [1, 4, 5].include?(state)
      '2'
    elsif state == 2
      '3'
    elsif state == 3
      '4'
    end
  end

  def order_push_message_to_user
    message = messages.create(user_id: user_id, title: '要货啦', info: '您好，系统已经收到您的订单！')
    if user.client_id.present?
      message.jpush_push_message(alert: message.info, client_id: user.client_id)
    end
  end

  def order_push_message
    if [1, 2].include?(state)
      info = state == 1 ? '您好，您的订单已经配货完成，现在送货中，请保持电话畅通！' : '您好，您的订单已经完成，如有问题，请联系客服。客服电话：400-0050-383 转1。'
      message = messages.where(user_id: user_id, title: '要货啦', info: info).first_or_create
      message.jpush_push_message(alert: message.info, client_id: user.client_id) if user.client_id.present?
    end
  end

  def change_orders_products_status(status)
    orders_products.each do |op|
      op.update(status: status)
    end
  end

  def get_address
    area.to_s + detail.to_s
  end

  def self.check_order_money(user, products)
    order_money = 0
    is_restricting = false
    send_out_num = 0
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      op = user.orders_products.where("product_id = ? and DATE(created_at) = ?", product.try(:id), Date.today).first
      op_product_num = op.try(:product_num).to_i + p['number'].to_i
      restricting_num = product.try(:restricting_num)
      if restricting_num.present? && (op_product_num > restricting_num.to_i)
        is_restricting = true
        break
      else
        order_money += product.price * p['number'].to_i
      end
      send_out_num += p['number'].to_i if product.category.try(:name) == '冷饮雪糕'
    end
    is_send_out = send_out_num > 0 && send_out_num < 5
    [order_money, is_restricting, is_send_out]
  end

  def update_order_money
    new_order_money = orders_products.to_a.sum do |op|
      op.product_price * op.product_num
    end
    self.update(order_money: new_order_money)
    if state == 1
      self.update(delivery_time: Time.now)
    elsif state == 2
      self.update(complete_time: Time.now)
    end
  end

  def restore_products
    orders_products.each do |op|
      op.product.restore_stock_num(op.product_num)
    end
  end

  def create_orders_products(products)
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      self.orders_products.create(user_id: user_id, product_id: product.try(:id), product_num: p['number'], product_price: product.try(:price).to_f, cost_price: product.try(:cost_price).to_f)
    end
  end

  def update_product_stock_num
    pro_ids = []
    orders_products.each do |op|
      if op.product.stock_num >= op.product_num
        pro_ids << op.product_id
        op.product.add_sale_count(op.product_num)
      else
        break
      end
    end
    pro_ids
  end

  def validate_product_stock_num
    result = []
    orders_products.each do |op|
      if op.product.stock_num < op.product_num || op.product.is_sold_off?
        next
      else
        result << op
      end
    end
    result
  end

  def self.get_order_stats(total, start_time, end_time)
    h = {}
    order_stats = total.select('date(created_at) as created_date, count(*) as count, sum(order_money) as money, sum(total_cost_price) as profit').group('date(created_at)').order("created_at asc")
    (start_time..end_time).to_a.reverse.each do |day|
      h[day.try(:strftime, "%Y-%m-%d")] = 0
    end
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%Y-%m-%d")] = [value.count, value.money, value.profit]
    end
    h.take(31)
  end

  def self.chart_data(orders, date, today, select_time, params)
    count = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '订单'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], count, total = Order.get_select_date(orders, start_time, end_time, count)
    else
      categories, hash['data'], count, start_time, end_time, total = Order.get_date(orders, date, today, count)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick, total]
  end

  def self.get_select_date(orders, start_time, end_time, count)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders.select_time(start_time, end_time)
    count = total.length
    if diff_time <= 31
      order_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    elsif diff_time > 31 &&  diff_time < 365
      order_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = Order.get_hash_month(h, order_stats)
    elsif diff_time > 365
      order_stats = total.select('year(created_at) as created_year, count(*) as count').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = Order.get_hash_year(h, order_stats)
    end
    return categories, data, count, total
  end

  def self.get_date(orders, date, today, count)
    h = {}
    total = orders.send(date, today)
    count = total.length
    order_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = Order.get_hash_day(h, order_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    end
    return categories, data, count, start_time, today, total
  end

  def self.get_hash_day(h, order_stats)
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.chart_base_line(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line1') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "订单量趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "订单量趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "个"
        })
      f.legend({
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  def self.chart_data_amount(orders, date, today, select_time, params)
    amount = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '订单'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], amount = Order.get_select_date_amount(orders, start_time, end_time, amount)
    else
      categories, hash['data'], amount, start_time, end_time = Order.get_date_amount(orders, date, today, amount)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, amount, min_tick]
  end

  def self.get_select_date_amount(orders, start_time, end_time, amount)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders.select_time(start_time, end_time)
    amount = total.sum(:order_money)
    if diff_time <= 31
      order_stats = total.select('date(created_at) as created_date, sum(order_money) as amount').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif diff_time > 31 &&  diff_time < 365
      order_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(order_money) as amount').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = Order.get_hash_month_amount(h, order_stats)
    elsif diff_time > 365
      order_stats = total.select('year(created_at) as created_year, sum(order_money) as amount').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = Order.get_hash_year_amount(h, order_stats)
    end
    return categories, data, amount
  end

  def self.get_date_amount(orders, date, today, amount)
    h = {}
    total = orders.send(date, today)
    amount = total.sum(:order_money)
    order_stats = total.select('date(created_at) as created_date, sum(order_money) as amount').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    end
    return categories, data, amount, start_time, today
  end

  def self.get_hash_day_amount(h, order_stats)
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month_amount(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year_amount(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.chart_base_line_amount(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line2') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "交易额趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "交易额趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "元"
        })
      f.legend({
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  def self.chart_data_profit(orders, date, today, select_time, params)
    profit = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '订单'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], profit = Order.get_select_date_profit(orders, start_time, end_time, profit)
    else
      categories, hash['data'], profit, start_time, end_time = Order.get_date_profit(orders, date, today, profit)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, profit, min_tick]
  end

  def self.get_select_date_profit(orders, start_time, end_time, profit)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders.select_time(start_time, end_time)
    profit = total.sum(:total_cost_price)
    if diff_time <= 31
      order_stats = total.select('date(created_at) as created_date, sum(total_cost_price) as profit').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_profit(h, order_stats)
    elsif diff_time > 31 &&  diff_time < 365
      order_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(total_cost_price) as profit').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = Order.get_hash_month_profit(h, order_stats)
    elsif diff_time > 365
      order_stats = total.select('year(created_at) as created_year, sum(total_cost_price) as profit').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = Order.get_hash_year_profit(h, order_stats)
    end
    return categories, data, profit
  end

  def self.get_date_profit(orders, date, today, profit)
    h = {}
    total = orders.send(date, today)
    profit = total.sum(:total_cost_price)
    order_stats = total.select('date(created_at) as created_date, sum(total_cost_price) as profit').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = Order.get_hash_day_profit(h, order_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_profit(h, order_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_profit(h, order_stats)
    end
    return categories, data, profit, start_time, today
  end

  def self.get_hash_day_profit(h, order_stats)
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.profit.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month_profit(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.profit.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year_profit(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.profit.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.chart_base_line_profit(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line3') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "订单利润趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "订单利润趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "元"
        })
      f.legend({
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
