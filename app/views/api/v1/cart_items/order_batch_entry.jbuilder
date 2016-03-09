if @stock_num_result == 3
  json.result 3
elsif @result
	json.result 0
else
  json.result 1
end
