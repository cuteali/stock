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

end
