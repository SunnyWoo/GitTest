class Api::V3::LayersController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_work

=begin
@api {get} /api/works/:work_uuid/layers Read layers of a work
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Layers
@apiName LayersList
@apiParam {String} work_uuid work uuid or work slug
@apiSuccessExample {json} Response-Example:
  {
    "layer": [
      {
        "id": 33,
        "uuid": "950907b6-2121-4942-8c4c-97d069849b43",
        "layer_type": "photo",
        "position_x": 0,
        "position_y": 0,
        "orientation": null,
        "scale_x": 0,
        "scale_y": 0,
        "transparent": 1,
        "color": "",
        "material_name": "",
        "font_name": "null",
        "font_text": "null",
        "text_alignment": "Left",
        "text_spacing_x": null,
        "text_spacing_y": null,
        "image": {
          "normal": "http://commandp.dev/uploads/layer/image/33/maxresdefault__1_.jpg?v=1454384762",
          "md5sum": "0ef1aa41094d8ea15e15c9ce7401d237"
        },
        "filter": "0",
        "filtered_image": {
          "normal": "http://commandp.dev/uploads/layer/filtered_image/33/762",
          "md5sum": "95c15c7853822d5130082182608648be"
        },
        "position": -1,
        "masked": false,
        "masked_layers": []
      }
    ]
  }
=end
  def index
    @layers = @work.layers
  end

  protected

  def find_work
    @work = current_user.works.find_by(slug: params[:work_id]) || current_user.works.find_by!(uuid: params[:work_id])
    log_with_current_user @work
  end
end
