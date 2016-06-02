module Admin::OrderHelper
  def order_state
    [["请选择",""],["不可用",-1],["已生效",0],["送货中",1],["已完成",2],["已取消",3]]
  end

  def order_state_show(state)
    state_show = "暂无"
    case state
    when -1
      state_show = "不可用"
    when 0
      state_show = "已生效"
    when 1
      state_show = "送货中"
    when 2
      state_show = "已完成"
    when 3
      state_show = "已取消"
    end
    state_show
  end

  def get_tr_color(state)
    state_color = ""
    case state
    when 0
      state_color = "info"
    when 2
      state_color = "success"
    when 3
      state_color = "warning"
    end
    state_color
  end

  def edit_disabled(state)
    [-1, 3].include?(state)
  end

  def get_select_product_html(product)
    return "<input type='text' name='product_price' id='product_price' class='form-control' value='#{product.price}'>"
  end
end