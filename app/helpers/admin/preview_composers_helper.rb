module Admin::PreviewComposersHelper
  def render_preview_composer_form(preview_composer)
    base_name = @preview_composer.class.name.demodulize.underscore
    render "#{base_name}_form", preview_composer: preview_composer
  end

  def preview_composer_form_path(preview_composer)
    if preview_composer.new_record?
      admin_product_model_preview_composers_path(preview_composer.product)
    else
      admin_product_model_preview_composer_path(preview_composer.product, preview_composer)
    end
  end
end
