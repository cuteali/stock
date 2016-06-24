module ApplicationHelper
  def full_title(page_title)
    page_title.empty? ? "要货啦" : "#{page_title}"
  end

  def time_show(time)
    time.strftime("%Y-%m-%d %H:%M:%S") if time.present?
  end

  def address_info
    address_arr = []
    address_arr << ["请选择",""]
    Address.all.each do |address|
      complete_address = address.province.to_s + " " + address.city.to_s + " " + address.region.to_s + " " + address.detail.to_s
      address_arr << [complete_address,address.id]
    end
    address_arr
  end

  def address_show(address)
    if address.present?
      # complete_address = address.province.to_s + " " + address.city.to_s + " " + address.region.to_s + " " + address.detail.to_s
      complete_address = address.area.to_s + " " + address.detail.to_s
    else
      complete_address = "暂无"
    end
    complete_address
  end

  def category_list
    categories = []
    categories << ["请选择",""]
    categories += Category.all.collect{|t| [t.name,t.id]}
  end

  def sub_category_list
    sub_categories = []
    sub_categories << ["请选择",""]
    sub_categories += SubCategory.all.collect{|t| [t.name,t.id]}
  end

  def detail_category_list
    detail_categories = []
    detail_categories << ["请选择",""]
    detail_categories += DetailCategory.all.collect{|t| [t.name,t.id]}
  end

  def hot_category_list
    hot_categories = []
    hot_categories << ["请选择",""]
    hot_categories += HotCategory.all.collect{|t| [t.name,t.id]}
  end

  def unit_list
    unit = []
    unit << ["请选择",""]
    unit += Unit.all.collect{|t| [t.name,t.id]}
  end

  def state_list
    state = []
    state << ["请选择",""]
    state += [["上架",1],["下架",0]]
  end

  def product_list
    products = []
    products << ["请选择",""]
    products += Product.all.collect{|t| [t.name,t.id]}
  end

  def user_list
    users = []
    users << ["请选择",""]
    users += User.all.collect{|t| [t.user_name,t.id]}
  end

  def invalid_path?
    return true if controller_name == 'welcomes'
    return true if controller_name == 'sessions' && action_name == 'new'
    return true if controller_name == 'passwords' && action_name == 'new'
    return true if controller_name == 'passwords' && action_name == 'edit'
  end

  def statistics_th_text(start_time, end_time, date)
    if start_time.present? && end_time.present?
      "#{start_time} - #{end_time}"
    else
      if date == 'one_days'
        '今日'
      elsif date == 'one_weeks'
        '最近7天'
      elsif date == 'one_months'
        '最近一个月'
      end
    end
  end

  def statistics_user_order_money(user, start_time, end_time, date, today)
    if start_time.present? && end_time.present?
      user.orders.select_time(start_time, end_time).sum(:order_money)
    else
      if date == 'one_days'
        user.orders.one_days(today).sum(:order_money)
      elsif date == 'one_weeks'
        user.orders.one_weeks(today).sum(:order_money)
      elsif date == 'one_months'
        user.orders.one_months(today).sum(:order_money)
      end
    end
  end

  def address_shop_type
    [["请选择",""],["社区便利店",0],["综合超市",1],["餐饮店",2],["酒店",3],["南北干货店",4],["炒货店",5],["休闲食品店",6],["其他店铺",7]]
  end

  def shop_type_name(shop_type)
    case shop_type
    when 0 then "社区便利店"
    when 1 then "综合超市"
    when 2 then "餐饮店"
    when 3 then "酒店"
    when 4 then "南北干货店"
    when 5 then "炒货店"
    when 6 then "休闲食品店"
    when 7 then "其他店铺"
    end
  end

  def current_member_can_visit?(controller)
    if current_member.user?
      %w(orders users promoters order_stat).include?(controller)
    elsif current_member.editor?
      %w(products orders units categories product_admins deliverymen order_stat product_stat).include?(controller)
    elsif current_member.spreader?
      %w(orders users order_stat).include?(controller)
    elsif current_member.admin?
      return true
    end
  end

  def order_ids(scope_ops, product_id)
    scope_ops.by_pro_ids(product_id).pluck(:order_id).uniq.join(',')
  end
end
