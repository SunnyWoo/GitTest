class AttachmentUploader < DefaultWithMetaUploader
  process :auto_orient
  process store_meta: [{ md5sum: true }], if: :image?

  def auto_orient
    return if !image? || svg?
    manipulate! do |img|
      img.auto_orient
      img
    end
  end
end
