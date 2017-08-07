cache_json_for json, @layer do
  json.layer do
    json.partial! 'api/v3/layer', layer: @layer
    json.layer_type @layer.layer_type_key
    json.name @layer.material_name
    json.work_id @layer.work.id
    json.work_uuid @layer.work.uuid
    json.image_url @layer.image.url
  end
end
