cache_json_for json, work do
  json.work_id work.id
  json.id work.uuid
  json.extract!(work, :name, :description)
  json.model work.product.name
  order_image = Monads::Optional.new(work.order_image)
  json.remote_order_image_url order_image.url.value
  json.extract!(work, :user_display_name)
  json.gid work.to_gid_param
  json.uuid work.uuid
end
