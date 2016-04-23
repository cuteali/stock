if @favorites
  json.result 0
  json.errmsg '获取收藏宝贝成功'
  json.favorites(@favorites) do |favorite|
    json.unique_id favorite.unique_id
    json.product_unique_id favorite.product.unique_id
    json.product_name favorite.product.name
    json.product_desc favorite.product.desc.to_s
    json.product_image Image.get_images(favorite.product).first.to_s
    json.product_unit favorite.product.unit.present?? favorite.product.unit.name.to_s : ""
    json.product_stock_num favorite.product.stock_num.to_s
    json.product_price favorite.product.price.to_s
    json.product_old_price favorite.product.old_price.to_s
    json.product_detail_category_id favorite.product.detail_category_id.to_s
    json.product_hot_category_id favorite.product.hot_category_id.to_s
    json.product_sale_count favorite.product.sale_count.to_s
    json.product_spec favorite.product.spec.to_s
    json.product_unit_price favorite.product.unit_price.to_s
    json.product_origin favorite.product.origin.to_s
    json.product_remark favorite.product.remark.to_s
  end
else
  json.result 1
  json.errmsg '获取收藏宝贝失败'\
end
