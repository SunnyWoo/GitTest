json.cache! [cache_key_for_collection(@des_images)] do
  json.des_images @des_images.each do |des|
    json.x1 des.image.x1.url
    json.x2 des.image.x2.url
    json.x3 des.image.url
  end
end
