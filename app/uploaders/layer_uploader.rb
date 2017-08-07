class LayerUploader < DefaultWithMetaUploader
  process :auto_orient
  process store_meta: [{ md5sum: true }], if: :image?
end
