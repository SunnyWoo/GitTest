# encoding: utf-8

class PrintUploader < DefaultWithMetaUploader
  attr_accessor :should_process
  process :density, if: :image?
  optimize!

  version :thumb do
    process resize_to_fit: [100, 100]
  end

  version :gray, if: :enable_white? do
    process :extract_alpha_to_grayscale
  end

  def should_process?
    model.is_a?(WorkOutputFile) ? @should_process ||= false : true
  end

  def density
    return if model.is_a?(WorkOutputFile)
    manipulate! do |img|
      img.combine_options do |c|
        c.units 'PixelsPerInch'
        c.density model.product.dpi
      end
    end
  end

  after :store, :enqueue_build_previews_by_print_image

  def extract_alpha_to_grayscale
    manipulate! do |img|
      img.combine_options do |c|
        c.alpha('extract')
        c.alpha('on')
        c.negate
      end
    end
  end

  def enqueue_build_previews_by_print_image(_file)
    model.print_image_stored! if model.respond_to?(:print_image_stored!)
  end

  def enable_white?(_picture)
    return unless should_process?
    model.product.enable_white?
  end
end
