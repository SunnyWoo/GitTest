class Store::Backend::ProductTemplatesController < Store::BackendController
  before_action :find_template, only: %w(edit update)

  def index
    @templates = current_store.templates.order(created_at: :desc).page(params[:page]).per_page(30)
  end

  def new
    @template = current_store.templates.build
  end

  def create
    @template = current_store.templates.build
    if @template.update(store_permitted_params.product_template)
      redirect_to edit_store_backend_product_template_design_path(@template), flash: { success: I18n.t('store.shared.create_success') }
    else
      flash[:error] = @template.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @template.update(store_permitted_params.product_template)
      redirect_to edit_store_backend_product_template_design_path(@template), flash: { success: I18n.t('store.shared.update_success') }
    else
      flash[:error] = @template.errors.full_messages
      render :edit
    end
  end

  private

  def find_template
    @template = current_store.templates.find(params[:id])
  end
end
