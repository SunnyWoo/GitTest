class Admin::ArchivedLayersController < AdminController
  def index
    @layers = ArchivedWork.find(params[:archived_work_id]).layers
    render 'api/v3/archived_layers/index'
  end

  def update
    @layer = ArchivedLayer.find(params[:id])
    log_with_current_admin @layer
    @layer.update_attributes(admin_permitted_params.layer)
    render 'api/v3/archived_layers/show'
  end
end
