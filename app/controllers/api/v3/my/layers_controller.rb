=begin
@apiDefine V3_My_LayerResponse
@apiSuccessExample {json} Response-Example:
{
  "layer": {
    "uuid": "da484a51-e124-427b-9f49-ed019b0f54c0",
    "layer_type": "photo",
    "position_x": 0,
    "position_y": 0,
    "orientation": 0,
    "scale_x": 1,
    "scale_y": 1,
    "transparent": 1,
    "color": null,
    "material_name": null,
    "font_name": null,
    "font_text": null,
    "text_alignment": null,
    "text_spacing_x": null,
    "text_spacing_y": null,
    "image": {
      "normal": null,
      "md5sum": ""
    },
    "filter": "0",
    "filtered_image": {
      "normal": null,
      "md5sum": ""
    },
    "position": 1,
    "masked": true,
    "masked_layers": [ { 'id' => 2, 'uuid' => 'a55845aa-76c9-11e4-9941-0c4de9c8b9e4' },...]
  }
}
=end
class Api::V3::My::LayersController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_work
  include FeatureFlag

=begin
  @api {put} /api/my/works/:work_uuid/layers/:uuid Create or Update work's layer
  @apiUse ApiV3
  @apiUse V3_My_LayerResponse
  @apiVersion 3.0.0
  @apiGroup MyLayers
  @apiName UpdateWorkLayer
  @apiParam {String= "camera", "photo",
  "background_color", "shape", "crop", "line", "sticker", "texture",
  "typography", "text", "lens_flare", "spot_casting", "spot_casting_text", "varnishing",
  "bronzing", "varnishing_typography", "bronzing_typography",
  "sticker_asset", "coating_asset", "foiling_asset", "mask", "frame"} layer_type layer type
  @apiParam {Integer} position position
  @apiParam {Integer} [mask_id] id of layer(layer_type = 'mask')
  @apiParam {Number} [position_x] x position
  @apiParam {Number} [position_y] y position
  @apiParam {Number} [orientation] orientation
  @apiParam {Number} [scale_x] scale_x
  @apiParam {Number} [scale_y] scale_y
  @apiParam {Number} [transparent] transparent
  @apiParam {String} [color] color
  @apiParam {String} [material_name] material_name
  @apiParam {String} [font_name] font_name
  @apiParam {String} [font_text] font_text
  @apiParam {String="Left", "Center", "Right"} [text_alignment] text_alignment
  @apiParam {Number} [text_spacing_x] text_spacing_x
  @apiParam {Number} [text_spacing_y] text_spacing_y
  @apiParam {File} [image] image
  @apiParam {String} [image_aid] image_aid
  @apiParam {File} [filtered_image] filtered_image
  @apiParam {String} [filtered_image_aid] filtered_image_aid
  @apiParam {String} [filter] filter
=end
  def update
    Layer.transaction do
      @layer = @work.layers.lock.find_or_initialize_by(uuid: params[:uuid])
      if @layer.mask?
        @layer.update!(masked_layer_params)
      else
        @layer.update!(layer_params)
      end
    end
    render :show
  end

=begin
  @api {delete} /api/my/works/:work_uuid/layers/:uuid Delete work's layer
  @apiUse ApiV3
  @apiUse V3_My_LayerResponse
  @apiVersion 3.0.0
  @apiGroup MyLayers
  @apiName DeleteWorkLayer
=end
  def destroy
    @layer = @work.layers.find_by!(uuid: params[:uuid])
    @layer.destroy
    render :show
  end

  private

  def find_work
    @work = current_user.works.find_by! uuid: params[:work_uuid]
  end

  def layer_params
    masked_layer_params.merge!(params.permit(:mask_id))
  end

  def masked_layer_params
    tmp = params.permit(:layer_type,
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
    if feature(:api_v3_my_layer_enable_attachment_aid).enable_for_current_session?
      image_aid = tmp.delete(:image_aid)
      tmp[:attached_image_id] = Attachment.find_by_aid!(image_aid).id if image_aid.present?
      filtered_image_aid = tmp.delete(:filtered_image_aid)
      tmp[:attached_filtered_image_id] = Attachment.find_by_aid!(filtered_image_aid).id if filtered_image_aid.present?
    end
    tmp
  end
end
