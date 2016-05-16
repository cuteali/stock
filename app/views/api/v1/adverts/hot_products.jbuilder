if @popular_product.blank?
  json.result 1
else
  json.result 0
  json.total_pages @popular_product.total_pages if params[:page_num]
  json.populars(@popular_product) do |pop_product|
    json.unique_id pop_product.unique_id.to_s
    json.name pop_product.name.to_s
    json.image Image.get_images(pop_product).first.to_s
    if pop_product.unit.present?
      json.unit pop_product.unit.name.to_s
    else
      json.unit ""
    end
    json.stock_num pop_product.stock_num.to_s
    json.price pop_product.price.to_s
    json.old_price pop_product.old_price.to_s
    json.detail_category_id pop_product.detail_category_id.to_s
    json.hot_category_id pop_product.hot_category_id.to_s
    json.sale_count pop_product.sale_count.to_s
    json.spec pop_product.spec.to_s
    if @user
      cart_item = pop_product.cart_items.where(user_id: @user.id).first
      json.cart_item_unique_id cart_item.try(:unique_id).to_s
      json.number cart_item.try(:product_num).to_s
    end
  end
end
