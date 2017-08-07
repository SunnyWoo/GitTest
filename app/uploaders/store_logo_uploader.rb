class StoreLogoUploader < DefaultWithMetaUploader
  version :s32 do
    process resize_to_fit: [32, 32]
  end

  version :s16 do
    process resize_to_fit: [16, 16]
  end
end
