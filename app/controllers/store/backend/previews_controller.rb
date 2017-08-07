class Store::Backend::PreviewsController < Store::BackendController
  def show
    @template = current_store.templates.find(params[:product_template_id])
  end
end
