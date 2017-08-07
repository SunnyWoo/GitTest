class ProductCategoryUploader < DefaultUploader
  version :s80 do
    process resize_to_fill: [80, 80]
  end

  version :s160 do
    process resize_to_fill: [160, 160]
  end
end
