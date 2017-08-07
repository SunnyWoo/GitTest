class Store::Backend::PreviewComposersController < Store::BackendController
  before_action :find_template

  def edit
    key = params[:key] || 'share'
    @composer = @template.preview_composers.find_or_create_by(key: key, type: 'PreviewComposer::Simple', product: @template.product, available: true)
  end

  def update
    @composer = @template.preview_composers.find_by(key: params[:key])
    if @composer.update preview_composer_params
      redirect_to next_path, flash: { success: I18n.t('store.shared.update_success') }
    else
      flash[:error] = @composer.errors.full_messsages
      render :edit
    end
  end

  protected

  def find_template
    @template = current_store.templates.find(params[:product_template_id])
  end

  def preview_composer_params
    params.require(:preview_composer).permit(
      [:id, :available, :position] + PreviewComposer::Simple.available_params
    )
  end

  def next_path
    params[:key] == 'share' ? edit_store_backend_product_template_preview_composers_path(@template, key: 'download') : store_backend_product_template_preview_path(@template)
  end
end
