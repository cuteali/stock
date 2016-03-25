if @adverts.blank?
  json.result 1
else
  json.result 0
  json.adverts(@adverts) do |advert|
    json.unique_id advert.unique_id
    json.product_unique_id advert.product.unique_id
    json.image_url Image.get_images(advert).first.to_s
  end
end
