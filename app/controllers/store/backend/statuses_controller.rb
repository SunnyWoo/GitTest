class Store::Backend::StatusesController < Store::BackendController
  before_action :find_template

  def edit
  end

  def update
    @form = Store::StatusForm.new(@template, store_permitted_params.product_template)
    if @form.save
      redirect_to store_backend_store_path, flash: { success: I18n.t('store.shared.update_success') }
    else
      flash[:error] = @form.errors.full_messages
      render :edit
    end
  end

  protected

  def find_template
    @template = current_store.templates.find(params[:product_template_id])
  end
end
