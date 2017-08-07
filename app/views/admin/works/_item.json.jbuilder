cache_json_for json, work do
  json.extract!(work, :id, :name, :description)
  json.remote_cover_image_url work.cover_image.url
  json.model work.product.name
  json.remote_print_image_url work.print_image.url
  json.remote_order_image_url work.order_image.url
  json.extract!(work, :user_display_name)
  json.gid work.to_gid_param
end
