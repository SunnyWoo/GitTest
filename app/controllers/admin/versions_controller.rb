class Admin::VersionsController < AdminController
  before_action :find_model

  def index
    @versions = @model.versions.reverse_order.page(params[:page])
  end

  def find_model
    @model = case
             when params[:work_id]           then Work.find(params[:work_id])
             when params[:product_model_id]  then ProductModel.find(params[:product_model_id])
             when params[:work_spec_id]      then WorkSpec.find(params[:work_spec_id])
             when params[:imposition_id]     then Imposition.find(params[:imposition_id])
             when params[:archived_layer_id] then ArchivedLayer.find(params[:archived_layer_id])
             else fail 'Need preferred id param'
             end
  end
end
