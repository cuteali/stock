if @product.present?
  json.result 0
  json.unique_id @product.unique_id.to_s
else
  json.result 1
  json.errmsg "扫一扫未找到商品\n请尝试输入产品名称搜索～"
end
