if @orders.blank?
  json.result 1
else
  json.result 0
  json.total_pages @orders.total_pages if params[:page_num]
  json.orders(@orders) do |order|
    json.unique_id order.unique_id.to_s
    json.order_no order.order_no.to_s
    json.receive_name order.receive_name.to_s
    json.phone_num order.phone_num.to_s  
    json.state order.state_return_value
    json.created_at order.created_at.present?? order.created_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.delivery_time order.delivery_time.present?? order.delivery_time.strftime("%Y-%m-%d %H:%M:%S").to_s : ""
    json.complete_time order.complete_time.present?? order.complete_time.strftime("%Y-%m-%d %H:%M:%S").to_s : ""
    json.address order.get_address.to_s
  end
end
