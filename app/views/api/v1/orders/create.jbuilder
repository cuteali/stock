if @order.present?
  json.result 0
elsif @stock_num_result == 3
	json.result 3
else
  json.result 1
end