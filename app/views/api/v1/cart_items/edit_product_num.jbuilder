if @cart_item.save
  json.result 0
else
  json.result 1
end