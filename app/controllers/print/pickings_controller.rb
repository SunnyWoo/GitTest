class Print::PickingsController < PrintController
  before_action :product_model, only: [:index, :update, :destroy]

  def index
    @product_model.picking_materials.build if @product_model.picking_materials.size == 0
  end

  def update
    authorize ProductModel, :pick?
    if @product_model.update_attributes(picking_materials_attributes: params[:product_model][:picking_materials_attributes])
      flash[:notice] = 'update success'
    else
      flash[:error] = @product_model.errors.full_messages
    end
    redirect_to :back
  end

  private

  def product_model
    @product_models = ProductModel.all
    if params[:model_id].present?
      @product_model = ProductModel.find(params[:model_id])
    else
      @product_model = @product_models.first
    end
  end
end
