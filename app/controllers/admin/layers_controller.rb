class Admin::LayersController < Admin::ResourcesController
  def update
    @layer = Layer.find(params[:id])
    log_with_current_admin @layer
    @layer.update_attributes(admin_permitted_params.layer)
  end
end
