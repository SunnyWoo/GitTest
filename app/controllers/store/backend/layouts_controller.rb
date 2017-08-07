class Store::Backend::LayoutsController < Store::BackendController
  def edit
    @tap_collection = [I18n.t('store.custom_product'), I18n.t('store.store_product')].zip(Store::TAPS)
  end

  def update
    if current_store.update(layout_params)
      redirect_to edit_store_backend_layout_path, flash: { success: I18n.t('store.shared.update_success') }
    else
      flash[:error] = current_store.errors.full_messages
      render :edit
    end
  end

  private

  def layout_params
    params.require(:store).permit(:title,
                                  :description,
                                  components_attributes: [
                                    :store_id, :id, :_destroy, :key, :content, :image
                                  ], tap_settings: [
                                    :default, :create_name, :shop_name
                                  ])
  end
end
