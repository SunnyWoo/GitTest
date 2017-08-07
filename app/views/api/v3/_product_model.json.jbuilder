product = Pricing::ProductDecorator.new(product) unless product.is_a?(Pricing::ProductDecorator)

json.call(product, :id, :key, :name, :description, :prices,
          :customized_special_prices, :design_platform, :customize_platform)
json.placeholder_image product.placeholder_image.url
json.call(product, :width, :height, :dpi)
json.background_image product.background_image.url
json.overlay_image product.overlay_image.url
json.padding_top product.padding_top.to_s
json.padding_right product.padding_right.to_s
json.padding_bottom product.padding_bottom.to_s
json.padding_left product.padding_left.to_s

if defined?(include_editor_optimization_images) && include_editor_optimization_images
  json.editor_optimization_images do
    json.overlay_image do
      json.x1 product.overlay_image.editor_optimization.x1.url
      json.x2 product.overlay_image.editor_optimization.x2.url
    end
  end
end

# TODO: remove this shit when spec can be remove safety
if defined?(include_specs) && include_specs
  json.specs do
    json.partial! 'api/v3/work_spec', collection: [product], as: :spec
  end
end
