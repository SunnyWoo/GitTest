class Store::Backend::DesignsController < Store::BackendController
  before_action :find_template
  before_action :set_form, only: %w(update)

  def edit
    template = current_store.templates.find(params[:product_template_id])
    settings = template.settings
    settings = settings.merge!(transparent: 1,
                               template_image: template.template_image.url,
                               template_type: template.template_type_for_editor,
                               max_width: settings.max_font_width,
                               orientation: settings.rotation)
    gon.editor_data = {
      oauth_config: {
        host: Settings.api_host,
        access_token: User.guest.first.access_token,
      },
      quality_text: '印刷品质:',
      product_model: @template.product.key,
      template: settings,
      product_width: @template.product_width,
      product_height: @template.product_height
    }
  end

  def update
    if @form.save
      @template.update_sample_work_cover_image
      redirect_to edit_store_backend_product_template_preview_composers_path(@template), flash: { success: I18n.t('store.shared.update_success') }
    else
      redirect_to edit_store_backend_product_template_design_path(@template), flash: { error: @form.errors.full_messages }
    end
  end

  private

  def find_template
    @template = current_store.templates.find(params[:product_template_id])
  end

  def set_form
    template = params[:product_template]
    @form = case params[:type]
            when 'photo_only_form'
              Store::PhotoOnlyForm.new(@template, template.slice(:template_image, :template_type))
            else
              Store::TextPhotoForm.new(@template, template[:settings].merge(template_image: template[:template_image],
                                                                            template_type: template[:template_type]))
            end
  end
end
