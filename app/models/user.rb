class User < ActiveRecord::Base
  belongs_to :promoter
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :images, as: :target, dependent: :destroy
  has_many :cart_items
  has_many :favorites
  has_many :orders_products
  has_many :messages

  scope :latest, -> { order('created_at DESC') }
  scope :one_days, ->(today) { where("date(created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :order_by_money, -> { joins("left join orders on orders.user_id=users.id").group("users.id").order("sum(orders.order_money) DESC, users.created_at DESC") }
  scope :client_users, -> { where("client_id is not null") }

  def is_verified?
    identification == 1
  end

  def self.sign_in(phone_num_encrypt, rand_code, params)
    redis_rand_code = $redis.get(phone_num_encrypt)
    phone = AesUtil.aes_dicrypt($key, phone_num_encrypt)
    token = nil
    unique_id = nil
    user = nil
    if %w(F59E10256A72D10742349BEBBFDD8FA8 D6694C9CC6FD5AC0D6EABF1C6CB04B9D).include?(phone_num_encrypt)
      if rand_code == "1111"
        #1.验证正确,存入cookies.
        token = SecureRandom.urlsafe_base64
        user = User.find_by(phone_num:phone_num_encrypt)
        if user.present?
          user.update(token: token, client_type: params[:client_type], client_id: params[:client_id])
        else
          user = User.create(token: token, phone_num: phone_num_encrypt, phone: phone, unique_id: SecureRandom.urlsafe_base64, rand: "铜", identification: 1, client_type: params[:client_type], client_id: params[:client_id])
        end
        unique_id = user.unique_id
      else
        token = nil
      end
    else
      if redis_rand_code == rand_code
        #1.验证正确,存入cookies.
        token = SecureRandom.urlsafe_base64
        user = User.find_by(phone_num:phone_num_encrypt)
        if user.present?
          user.update(token:token, client_type: params[:client_type], client_id: params[:client_id])
        else
          user = User.create(token: token, phone_num: phone_num_encrypt, phone: phone, unique_id: SecureRandom.urlsafe_base64, rand: "铜", identification: 1, client_type: params[:client_type], client_id: params[:client_id])
        end
        unique_id = user.unique_id
      else
        token = nil
      end
    end

    [token,unique_id,user]
  end

  def self.chart_data(users, date, today, select_time, params)
    count = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '用户'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], count, total = User.get_select_date(users, start_time, end_time, count)
    else
      categories, hash['data'], count, start_time, end_time, total = User.get_date(users, date, today, count)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick, total]
  end

  def self.get_select_date(users, start_time, end_time, count)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = users.select_time(start_time, end_time)
    count = total.length
    if diff_time <= 31
      user_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = User.get_hash_day(h, user_stats)
    elsif diff_time > 31 &&  diff_time < 365
      user_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = User.get_hash_month(h, user_stats)
    elsif diff_time > 365
      user_stats = total.select('year(created_at) as created_year, count(*) as count').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = User.get_hash_year(h, user_stats)
    end
    return categories, data, count, total
  end

  def self.get_date(users, date, today, count)
    h = {}
    total = users.send(date, today)
    count = total.length
    user_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = User.get_hash_day(h, user_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = User.get_hash_day(h, user_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = User.get_hash_day(h, user_stats)
    end
    return categories, data, count, start_time, today, total
  end

  def self.get_hash_day(h, user_stats)
    user_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month(h, user_stats)
    user_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year(h, user_stats)
    user_stats.each do |value|
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
      f.title({ text: "推广用户趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "推广用户趋势图"},
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
end
