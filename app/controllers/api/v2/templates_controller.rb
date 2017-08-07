class Api::V2::TemplatesController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_product_model

=begin
@api {get} /api/product_models/:product_model_id/templates Get template list
@apiUse NeedAuth
@apiGroup My/Templates
@apiName GetMyTemplates
@apiVersion 2.0.0
@apiParam {Integer} product_model_id ProductModel#id
@apiSuccessExample {json} Success-Response:
  {
    "templates": [{
       id: 1,
       background_image: {
         w320: 'http://...',
         w640: 'http://...',
       },
       overlay_image: {
         w320: 'http://...',
         w640: 'http://...',
       },
       masks: {
         material_name: 'mask01',
         scale_x: 1,
         scale_y: 1,
         position_x: 0,
         position_y: 0,
         orientation: 0
        }
    }]
  }
=end
  def index
    @templates = @product_model.templates.published
    render 'api/v3/templates/index'
  end

  private

  def find_product_model
    @product_model = ProductModel.find(params[:product_model_id])
  end
end
