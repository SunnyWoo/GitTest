cache_json_for json, work do
  json.extract!(work, :id, :model_id, :user_id, :user_type, :name,
                :price_tier_id, :featured, :uuid)
  json.model_id work.model_id
  json.model work.product.try(:name)
  json.print_image_url work.print_image.url
  if work.product.try(&:enable_white?).to_b
    json.print_image_gray_url work.print_image.gray.url
  end
  json.tag_ids work.tag_ids
  json.previews do
    json.partial! 'api/v3/preview', collection: work.previews, as: :preview
  end
  json.output_files do
    json.partial! 'api/v3/work_output_file', collection: work.output_files, as: :output_file
  end
end
