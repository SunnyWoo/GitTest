class Admin::StoresController < Admin::ResourcesController
  def index
    @search = Store.ransack(params[:q])
    @resources = @search.result.page(params[:page] || 1)
  end

  def update
    @resource = model_class.find(params[:id])
    if @resource.update(admin_permitted_params.store.keep_if { |_k, v| v.present? })
      redirect_to admin_stores_path, flash: { success: I18n.t('store.shared.update_success') }
    else
      flash.now[:error] = @resource.errors.full_messages
      render :edit
    end
  end
end
