class StoreComponentImageUploader < DefaultWithMetaUploader
  version :x_1, if: :kv_image? do
    process resize_to_fit: [414, 200]
  end

  version :x_2, if: :kv_image? do
    process resize_to_fit: [621, 300]
  end

  def kv_image?(_picture)
    model.key == 'kv'
  end
end
