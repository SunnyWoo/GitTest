class Product::ExportService
  attr_accessor :ids

  def initialize(ids)
    @ids = ids
  end

  def execute
    ProductModel.where(id: ids).map do |product|
      {
        product_key: product.key,
        category: export_product_category_attrs(product),
        attributes: export_product_attrs(product),
        preview_composers: export_product_preview_composers_atts(product)
      }
    end.to_json
  end

  private

  def export_product_category_attrs(product)
    category = product.category
    {
      key: category.key,
      name_zh_tw: category.name_zh_tw,
      name_zh_cn: category.name_zh_cn,
      name_en: category.name_en,
      name_ja: category.name_ja,
      name_zh_hk: category.name_zh_hk
    }
  end

  def export_product_attrs(product)
    attrs = {
      slug: product.slug,
      key: product.key,
      dir_name: product.dir_name,
      material: product.material,
      weight: product.weight,
      enable_white: product.enable_white,
      auto_imposite: product.auto_imposite,
      name_zh_tw: product.name_zh_tw,
      description_zh_tw: product.description_zh_tw,
      short_name_zh_tw: product.short_name_zh_tw,
      name_zh_cn: product.name_zh_cn,
      description_zh_cn: product.description_zh_cn,
      short_name_zh_cn: product.short_name_zh_cn,
      name_en: product.name_en,
      description_en: product.description_en,
      short_name_en: product.short_name_en,
      name_ja: product.name_ja,
      description_ja: product.description_ja,
      short_name_ja: product.short_name_ja,
      name_zh_hk: product.name_zh_hk,
      description_zh_hk: product.description_zh_hk,
      short_name_zh_hk: product.short_name_zh_hk,
      aasm_state: product.aasm_state,
      external_code: product.external_code,
      width: product.width,
      height: product.height,
      dpi: product.dpi,
      shape: product.shape,
      alignment_points: product.alignment_points,
      background_color: product.background_color,
      padding_top: product.padding_top,
      padding_right: product.padding_right,
      padding_bottom: product.padding_bottom,
      padding_left: product.padding_left,
      enable_composite_with_horizontal_rotation: product.enable_composite_with_horizontal_rotation,
      create_order_image_by_cover_image: product.create_order_image_by_cover_image,
    }
    attrs[:remote_placeholder_image_url] = product.placeholder_image.url if product.placeholder_image.url.present?
    attrs[:remote_print_image_mask_url] = product.print_image_mask.url if product.print_image_mask.url.present?
    attrs[:remote_watermark_url] = product.watermark.url if product.watermark.url.present?
    attrs[:remote_background_image_url] = product.background_image.url if product.background_image.url.present?
    attrs[:remote_overlay_image_url] = product.overlay_image.url if product.overlay_image.url.present?
    attrs
  end

  def export_product_preview_composers_atts(product)
    product.preview_composers.map do |pc|
      data = {
        key: pc.key,
        type: pc.type,
        available: pc.available,
        position: pc.position,
        layers: pc.layers
      }
      data[:layers] = data[:layers].each_with_object({}) { |(k, v), h| k =~ /_filename/ ? nil : h[k] = v; h }
      data.merge!(data.delete(:layers))
      data[:case_file] = pc.case.uploader.url if pc.respond_to?(:case) && pc.case.uploader.present?
      data[:left_mask_file] = pc.left_mask.uploader.url if pc.respond_to?(:left_mask) && pc.left_mask.uploader.present?
      data[:right_mask_file] = pc.right_mask.uploader.url if pc.respond_to?(:right_mask) && pc.right_mask.uploader.present?
      data[:mask_file] = pc.mask.uploader.url if pc.respond_to?(:mask) && pc.mask.uploader.present?
      data[:image_file] = pc.image.uploader.url if pc.respond_to?(:image) && pc.image.uploader.url
      data[:background_file] = pc.background.uploader.url if pc.respond_to?(:background) && pc.background.uploader.url
      data
    end
  end
end
