if @order.blank?
  json.result 1
else
  json.result 0
  json.order do 
    json.unique_id @order.unique_id.to_s
    json.order_no @order.order_no.to_s
    json.receive_name @order.receive_name.to_s
    json.phone_num @order.phone_num.to_s  
    json.state @order.state_return_value
    json.created_at @order.created_at.present?? @order.created_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.delivery_time @order.delivery_time.present?? @order.delivery_time.strftime("%Y-%m-%d %H:%M:%S").to_s : ""
    json.complete_time @order.complete_time.present?? @order.complete_time.strftime("%Y-%m-%d %H:%M:%S").to_s : ""
    json.address @order.get_address.to_s
    json.order_money @order.order_money.to_s
    json.remarks @order.remarks.to_s
    if @order.orders_products.present?
      json.products(@products) do |op|
        json.unique_id op.product.unique_id.to_s
        json.number op.product_num.to_s
        if op.product.present?
          json.name op.product.name.to_s
          json.image Image.get_images(op.product).first.to_s
          json.unit if op.product.unit.present?? op.product.unit.name.to_s : ""
          json.stock_num op.product.stock_num.to_s
          json.price op.product.price.to_s
          json.old_price op.product.old_price.to_s
          json.detail_category_id op.product.detail_category_id.to_s
          json.hot_category_id op.product.hot_category_id.to_s
          json.sale_count op.product.sale_count.to_s
          json.spec op.product.spec.to_s
          json.unit_price op.product.unit_price.to_s
          json.origin op.product.origin.to_s
          json.remark op.product.remark.to_s
          json.minimum op.product.minimum.to_s
        end
      end
    end
  end
end
