class ProductAdmin < ActiveRecord::Base
  belongs_to :product

  scope :latest, -> { order('created_at DESC') }
  scope :one_days, ->(today) { where("date(created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }

  def sum_price
    product_num.to_i * stock_price.to_f
  end

  def self.get_product_admin_stats(total, start_time, end_time)
    h = {}
    product_admin_stats = total.select('date(created_at) as created_date, sum(product_num) as num, sum(product_num * stock_price) as price').group('date(created_at)').order("created_at asc")
    (start_time..end_time).to_a.reverse.each do |day|
      h[day.try(:strftime, "%Y-%m-%d")] = 0
    end
    product_admin_stats.each do |value|
      h[value.created_date.try(:strftime, "%Y-%m-%d")] = [value.num, value.price]
    end
    h.take(31)
  end

  def self.chart_data(product_admins, date, today, select_time, params)
    count = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '进货量'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], count, total = ProductAdmin.get_select_date(product_admins, start_time, end_time, count)
    else
      categories, hash['data'], count, start_time, end_time, total = ProductAdmin.get_date(product_admins, date, today, count)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick, total]
  end

  def self.get_select_date(product_admins, start_time, end_time, count)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = product_admins.select_time(start_time, end_time)
    count = total.sum(:product_num)
    if diff_time <= 31
      product_admin_stats = total.select('date(created_at) as created_date, sum(product_num) as num').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day(h, product_admin_stats)
    elsif diff_time > 31 &&  diff_time < 365
      product_admin_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(product_num) as num').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = ProductAdmin.get_hash_month(h, product_admin_stats)
    elsif diff_time > 365
      product_admin_stats = total.select('year(created_at) as created_year, sum(product_num) as num').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = ProductAdmin.get_hash_year(h, product_admin_stats)
    end
    return categories, data, count, total
  end

  def self.get_date(product_admins, date, today, count)
    h = {}
    total = product_admins.send(date, today)
    count = total.sum(:product_num)
    product_admin_stats = total.select('date(created_at) as created_date, sum(product_num) as num').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = ProductAdmin.get_hash_day(h, product_admin_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day(h, product_admin_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day(h, product_admin_stats)
    end
    return categories, data, count, start_time, today, total
  end

  def self.get_hash_day(h, product_admin_stats)
    product_admin_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.num
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month(h, product_admin_stats)
    product_admin_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.num
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year(h, product_admin_stats)
    product_admin_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.num
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
      f.title({ text: "进货量趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "进货量趋势图"},
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

  def self.chart_data_amount(product_admins, date, today, select_time, params)
    amount = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '进货金额'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], amount = ProductAdmin.get_select_date_amount(product_admins, start_time, end_time, amount)
    else
      categories, hash['data'], amount, start_time, end_time = ProductAdmin.get_date_amount(product_admins, date, today, amount)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, amount, min_tick]
  end

  def self.get_select_date_amount(product_admins, start_time, end_time, amount)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = product_admins.select_time(start_time, end_time)
    amount = total.map(&:sum_price).inject(:+)
    if diff_time <= 31
      product_admin_stats = total.select('date(created_at) as created_date, sum(product_num * stock_price) as price').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day_amount(h, product_admin_stats)
    elsif diff_time > 31 &&  diff_time < 365
      product_admin_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(product_num * stock_price) as price').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = ProductAdmin.get_hash_month_amount(h, product_admin_stats)
    elsif diff_time > 365
      product_admin_stats = total.select('year(created_at) as created_year, sum(product_num * stock_price) as price').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = ProductAdmin.get_hash_year_amount(h, product_admin_stats)
    end
    return categories, data, amount
  end

  def self.get_date_amount(product_admins, date, today, amount)
    h = {}
    total = product_admins.send(date, today)
    amount = total.map(&:sum_price).inject(:+)
    product_admin_stats = total.select('date(created_at) as created_date, sum(product_num * stock_price) as price').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = ProductAdmin.get_hash_day_amount(h, product_admin_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day_amount(h, product_admin_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = ProductAdmin.get_hash_day_amount(h, product_admin_stats)
    end
    return categories, data, amount, start_time, today
  end

  def self.get_hash_day_amount(h, product_admin_stats)
    product_admin_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.price.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month_amount(h, product_admin_stats)
    product_admin_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.price.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year_amount(h, product_admin_stats)
    product_admin_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.price.to_f
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
      f.title({ text: "进货金额趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "进货金额趋势图"},
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
end
