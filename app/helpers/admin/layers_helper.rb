module Admin::LayersHelper
  def toggle_layer_button(layer:, label:, value:)
    link_to label, url_for([:admin, layer, layer: { disabled: value }]),
            id: dom_id(layer, :toggle),
            class: 'btn btn-default btn-xs',
            remote: true,
            method: 'patch',
            format: 'js'
  end

  def enable_layer_button(layer)
    toggle_layer_button(layer: layer, label: t('shared.form_actions.enable'), value: false)
  end

  def disable_layer_button(layer)
    toggle_layer_button(layer: layer, label: t('shared.form_actions.disable'), value: true)
  end

  def layer_image_tag(layer)
    image = case layer.layer_type
            when 'photo', 'camera', 'text' then layer.image
            when 'mask'                    then layer.mask_image
            end
    return unless image
    image_container = image_tag(image.thumb.url, class: 'transparent-grid dashed-border')
    link_to image_container, image.url, target: '_blank'
  end

  def layer_filtered_image_tag(layer)
    image = case layer.layer_type
            when 'photo', 'camera', 'text' then layer.filtered_image
            when 'mask'                    then layer.mask_image
            end
    return unless image
    image_container = image_tag(image.thumb.url, class: 'transparent-grid dashed-border')
    link_to image_container, image.url, target: '_blank' if image
  end
end
