if @product.present?
  json.result 0
  json.unique_id @product.unique_id.to_s
else
  json.result 1
  json.errmsg '产品未找到'
end
