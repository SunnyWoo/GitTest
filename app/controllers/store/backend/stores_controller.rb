class Store::Backend::StoresController < Store::BackendController
  def show
  end

  def edit
  end

  def update
    if current_store.update(store_permitted_params.store.keep_if { |_k, v| v.present? })
      redirect_to store_backend_store_path, flash: { success: I18n.t('store.shared.update_success') }
    else
      flash[:error] = current_store.errors.full_messages
      render :edit
    end
  end
end
