=begin
@apiDefine LayerResponse
@apiSuccessExample {json} Success-Response:
  {
    "uuid": "a55845aa-76c9-11e4-9941-0c4de9c8b9e5",
    "layer_type": "photo",
    "position_x": 40.300247,
    "position_y": 0.0,
    "orientation": 0.0,
    "scale_x": 0.245300725102425,
    "scale_y": 0.245300725102425,
    "transparent": 1.0,
    "color": "0x000000",
    "material_name": "19B8A0FE-B18E-4CA6-80BA-C7B35D11EAD7",
    "font_name": null,
    "font_text": null,
    "text_alignment": "Left",
    "text_spacing_x": null,
    "text_spacing_y": null,
    "image": {
      "normal": null,
      "md5sum": "d6f347ce15c6f68ac4a70483ac4c5380"
    },
    "filtered_image": {
      "normal": "http://commandp.dev/uploads/layer/filtered_image/519/blah.jpg?v=14116",
      "md5sum": "d6f347ce15c6f68ac4a70483ac4c5380"
    },
    "filter": "0",
    "position": 1,
    "masked": true,
    "masked_layers": [ { 'id' => 2, 'uuid' => 'a55845aa-76c9-11e4-9941-0c4de9c8b9e4' },...]
  }
=end
class Api::V2::My::LayersController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_work

=begin
@api {put} /api/my/works/:work_uuid/layers/:uuid Create or update the layer
@apiUse NeedAuth
@apiUse LayerResponse
@apiGroup My/Layers
@apiName PutLayer
@apiVersion 2.0.0
@apiParam {Integer} mask_id id of layer(layer_type = 'mask')
@apiParamExample {json} Request-Example
  # PUT http://commandp.dev/api/my/works/a97d6178-5a0a-11e4-9030-3c15c2d24fd8/layers/6edc3102-5505-11e4-8170-3c15c2d24fd8
  {
     auth_token: '2337832c5e9a770c41d4db73875c9423',
     layer_type: 'shape',
     position_x: 100,
     position_y: 200,
     orientation: 90,
     scale_x: 1,
     scale_y: 1,
     transparent: 0.5,
     color: '0xfafa50',
     material_name: 'shape_01',
     font_name: 'Noto',
     font_text: 'Yo',
     text_alignment: 'Left',
     image: <file>,
     filtered_image: <file>,
     filter: "whatever",
     position: 1,
     mask_id: 1
  }
=end
  def update
    @layer = @work.layers.find_or_initialize_by(uuid: params[:uuid])
    log_with_current_user @layer
    if @layer.mask?
      @layer.update!(masked_layer_params)
    else
      @layer.update!(layer_params)
    end
    @layer.reload
    render 'api/v3/my/layers/show'
  end

=begin
@api {delete} /api/my/works/:work_uuid/layers/:uuid Remove my layer
@apiUse NeedAuth
@apiUse LayerResponse
@apiGroup My/Layers
@apiName DeleteLayer
@apiVersion 2.0.0
=end
  def destroy
    @layer = @work.layers.find_by(uuid: params[:uuid])
    if @layer
      log_with_current_user @layer
      @layer.destroy
    end
    render 'api/v3/my/layers/show'
  end

  private

  def find_work
    @work = current_user.works.find_by!(uuid: params[:work_uuid])
    log_with_current_user @work
  end

  def layer_params
    masked_layer_params.merge!(params.permit(:mask_id))
  end

  def masked_layer_params
    params.permit(:layer_type,
                  :position_x, :position_y,
                  :orientation,
                  :scale_x, :scale_y,
                  :transparent, :color,
                  :material_name,
                  :font_name, :font_text,
                  :text_alignment,
                  :text_spacing_x, :text_spacing_y,
                  :image, :image_aid,
                  :filtered_image, :filtered_image_aid,
                  :filter,
                  :position)
  end
end
