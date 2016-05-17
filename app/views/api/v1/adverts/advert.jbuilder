if @adverts.blank?
  json.result 1
else
  json.result 0
  json.adverts(@adverts) do |advert|
    json.unique_id advert.unique_id
    json.product_unique_id advert.product.unique_id
    json.image_url Image.get_images(advert).first.to_s
  end
  json.categories(@categories) do |category|
    json.unique_id category.unique_id.to_s
    json.name category.desc.to_s
    json.image Image.get_images(category).first.to_s
  end
end
