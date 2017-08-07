module ProductModel::VariantBuilder
  extend ActiveSupport::Concern

  included do
    before_create :build_variant
  end

  def build_variant
    variants.build(work_spec_attributes: work_spec_attributes)
  end

  def work_spec_attributes
    {
      name: name,
      width: width,
      height: height,
      dpi: dpi,
      background_image: file_exists_check(background_image.file),
      overlay_image: file_exists_check(overlay_image.file),
      shape: shape,
      alignment_points: alignment_points,
      padding_top: padding_top.present? ? padding_top : 0,
      padding_right: padding_right.present? ? padding_top : 0,
      padding_bottom: padding_bottom.present? ? padding_top : 0,
      padding_left: padding_left.present? ? padding_top : 0,
      background_color: background_color.present? ? background_color : 'white',
      variant: variants.first,
      dir_name: dir_name,
      placeholder_image: file_exists_check(placeholder_image.file),
      enable_white: enable_white,
      auto_imposite: auto_imposite,
      watermark: file_exists_check(watermark.file),
      print_image_mask: file_exists_check(print_image_mask.file),
      enable_composite_with_horizontal_rotation: enable_composite_with_horizontal_rotation,
      create_order_image_by_cover_image: create_order_image_by_cover_image,
      enable_back_image: enable_back_image
    }
  end

  private

  def file_exists_check(file)
    return nil if file.nil? || !file.exists?
    file
  end
end
