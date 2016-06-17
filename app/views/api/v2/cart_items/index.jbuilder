if @cart_items.blank?
  json.result 1
else
  json.result 0
  json.delivery_price @delivery_price
  json.cart_total_num @cart_item_total_num
  json.cart_items(@cart_items) do |key, values|
    json.category_name key
    json.set! 'list' do
      json.array! values do |cart_item|
        json.unique_id cart_item.unique_id.to_s
        json.product_unique_id cart_item.product.present? ? cart_item.product.unique_id.to_s : ""
        json.product_num cart_item.product_num.to_s
        json.product_name cart_item.product.name.to_s
        json.product_image Image.get_images(cart_item.product).first.to_s
        json.product_unit if cart_item.product.unit.present?? cart_item.product.unit.name : ""
        json.product_stock_num cart_item.product.stock_num.to_s
        json.product_price cart_item.product.price.to_s
        json.product_old_price cart_item.product.old_price.to_s
        json.product_detail_category_id cart_item.product.detail_category_id.to_s
        json.product_hot_category_id cart_item.product.hot_category_id.to_s
        json.product_sale_count cart_item.product.sale_count.to_s
        json.product_spec cart_item.product.spec.to_s
        json.product_unit_price cart_item.product.unit_price.to_s
        json.product_origin cart_item.product.origin
        json.product_remark cart_item.product.remark
      end
    end
  end
end
