if !@user.is_verified?
  json.result 4
elsif @stock_num_result == 3
  json.result 3
elsif @order.present?
	json.result 0
else
  json.result 1
end