class DefaultWithMetaUploader < DefaultUploader
  include ::CarrierWave::Backgrounder::Delay
  prepend_process :store_md5sum_meta
  process store_meta: [{ md5sum: true }], if: :image?

  def store_md5sum_meta
    self.md5sum = Digest::MD5.hexdigest(File.read(file.path)) if file.present?
  end

  def thumb
    on_the_fly_process(resize_to_fit: [100, 100])
  end

  def negate
    on_the_fly_process(process_negate: true)
  end

  def process_negate(*)
    manipulate! do |img|
      img.negate
      img
    end
  end
  # Protected: 使用後台上傳圖片時建立的 Crop 版本
  #
  # Returns MiniMagick image instance
  def crop
    if model.try(:crop_x).present?
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop("%dx%d!%+d%+d" % [w, h, x, y])
        img.combine_options do |c|
          c.units 'PixelsPerInch'
          c.density '300'
        end
        img
      end
    end
  end
end
