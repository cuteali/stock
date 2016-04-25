class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :user
  has_many :orders_products, dependent: :destroy
  has_many :products, through: :orders_products
  accepts_nested_attributes_for :orders_products, allow_destroy: true

  validates :order_no, uniqueness: true

  before_create :generate_order_no

  scope :latest, -> { order('created_at DESC') }
  scope :one_days, ->(today) { where("date(created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }

  def get_address
    area.to_s + detail.to_s
  end

  def self.check_order_money(products)
    order_money = 0
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      order_money += product.price * p['number'].to_i
    end
    order_money
  end

  def update_order_money
    new_order_money = orders_products.to_a.sum do |op|
      op.product_price * op.product_num
    end
    self.update(order_money: new_order_money)
  end

  def restore_products
    orders_products.each do |op|
      op.product.restore_stock_num(op.product_num)
    end
  end

  def create_orders_products(products)
    products.each do |p|
      product = Product.find_by(unique_id: p['unique_id'])
      self.orders_products.where(product_id: product.try(:id), product_num: p['number'], product_price: product.try(:price)).first_or_create
    end
  end

  def update_product_stock_num
    pro_ids = []
    orders_products.each do |op|
      if op.product.stock_num >= op.product_num
        pro_ids << op.product_id
        op.product.stock_num -= op.product_num
        op.product.sale_count += op.product_num
        op.product.save
      else
        break
      end
    end
    pro_ids
  end

  def validate_product_stock_num
    result = 0
    orders_products.each do |op|
      if op.product.stock_num < op.product_num
        result = 3
        break
      end
    end
    result
  end

  def self.get_order_stats(total, start_time, end_time)
    h = {}
    order_stats = total.select('date(created_at) as created_date, count(*) as count, sum(order_money) as money').group('date(created_at)').order("created_at asc")
    (start_time..end_time).to_a.reverse.each do |day|
      h[day.try(:strftime, "%Y-%m-%d")] = 0
    end
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%Y-%m-%d")] = [value.count, value.money]
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

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
