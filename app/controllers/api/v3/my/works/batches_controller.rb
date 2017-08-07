class Api::V3::My::Works::BatchesController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user

=begin
@api {put} /api/my/works/batches/:uuid Create or update the work with layers at once
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MyWorkBatch
@apiName UpdateMyWorkBatch
@apiParam {String} [uuid] work's uuid
@apiParam {String} [name] work name
@apiParam {Integer} [model_id] model's id
@apiParam {Integer} [spec_id] spec's id
@apiParam {File} [cover_image] cover image
@apiParam {String} [cover_image_aid] cover_image's aid
@apiParam {Boolean} perform_destroy_previews set it true to destroy previews
@apiParam {Boolean} finish set work to be finished if provided
@apiParam {Object[]} layers_attributes layers' structure
@apiParam {Number} layers_attributes.id layer's id, provided for update, otherwise for create
@apiParam {String= "camera", "photo",
"background_color", "shape", "crop", "line", "sticker", "texture",
"typography", "text", "lens_flare", "spot_casting", "spot_casting_text", "varnishing",
"bronzing", "varnishing_typography", "bronzing_typography",
"sticker_asset", "coating_asset", "foiling_asset", "mask", "frame"} layers_attributes.layer_type layer type
@apiParam {Integer} layers_attributes.position position
@apiParam {Integer} [layers_attributes.mask_id] id of layer(layer_type = 'mask')
@apiParam {Number} [layers_attributes.position_x] x position
@apiParam {Number} [layers_attributes.position_y] y position
@apiParam {Number} [layers_attributes.orientation] orientation
@apiParam {Number} [layers_attributes.scale_x] scale_x
@apiParam {Number} [layers_attributes.scale_y] scale_y
@apiParam {Number} [layers_attributes.transparent] transparent
@apiParam {String} [layers_attributes.color] color
@apiParam {String} [layers_attributes.material_name] material_name
@apiParam {String} [layers_attributes.font_name] font_name
@apiParam {String} [layers_attributes.font_text] font_text
@apiParam {String="Left", "Center", "Right"} [layers_attributes.text_alignment] text_alignment
@apiParam {Number} [layers_attributes.text_spacing_x] text_spacing_x
@apiParam {Number} [layers_attributes.text_spacing_y] text_spacing_y
@apiParam {File} [layers_attributes.image] image
@apiParam {String} [layers_attributes.image_aid] image_aid
@apiParam {File} [layers_attributes.filtered_image] filtered_image
@apiParam {String} [layers_attributes.filtered_image_aid] filtered_image_aid
@apiParam {String} [layers_attributes.filter] filter
@apiSuccessExample {json} Response-Example:
{
  "work": {
    "id": 3778,
    "gid": "Z2lkOi8vY29tbWFuZC1wL1dvcmsvMzc3OA",
    "uuid": "2e133be0-9101-11e6-9fc8-ac87a30f9d14",
    "name": "lala",
    "user_id": 1,
    "user_avatar": {
      "avatar": {
        "url": "http://commandp.dev/uploads/user/avatar/1/03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316",
        "s35": {
          "url": "http://commandp.dev/uploads/user/avatar/1/s35_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316"
        },
        "s114": {
          "url": "http://commandp.dev/uploads/user/avatar/1/s114_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316"
        },
        "s154": {
          "url": "http://commandp.dev/uploads/user/avatar/1/s154_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316"
        }
      }
    },
    "order_image": {
      "thumb": null,
      "share": null,
      "sample": null,
      "normal": null
    },
    "gallery_images": [],
    "prices": {
      "TWD": 899,
      "USD": 29.95,
      "JPY": 3480,
      "HKD": 229
    },
    "original_prices": {
      "TWD": 899,
      "USD": 29.95,
      "JPY": 3480,
      "HKD": 229
    },
    "user_display_name": "",
    "wishlist_included": false,
    "slug": "wtf",
    "is_public": false,
    "user_avatars": {
      "s35": "http://commandp.dev/uploads/user/avatar/1/s35_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316",
      "s154": "http://commandp.dev/uploads/user/avatar/1/s154_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1476334316"
    },
    "spec": {
      "id": 8,
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機\r\n- 熱轉印特殊防刮抗磨塑料",
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0",
      "__deprecated": "WorkSpec is not longer available"
    },
    "model": {
      "id": 8,
      "key": "iphone_6plus_cases",
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機\r\n- 熱轉印特殊防刮抗磨塑料",
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "customized_special_prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "design_platform": {
        "ios": true,
        "android": true,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": true
      },
      "placeholder_image": null,
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0"
    },
    "product": {
      "id": 8,
      "key": "iphone_6plus_cases",
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機\r\n- 熱轉印特殊防刮抗磨塑料",
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "customized_special_prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "design_platform": {
        "ios": true,
        "android": true,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": true
      },
      "placeholder_image": null,
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0"
    },
    "category": {
      "id": 5,
      "key": "case",
      "name": "手機殼"
    },
    "featured": false,
    "layers": [
      {
        "id": 277,
        "uuid": "d8c36232-9105-11e6-a45b-ac87a30f9d14",
        "layer_type": "text",
        "position_x": 0,
        "position_y": 0,
        "orientation": 0,
        "scale_x": 1,
        "scale_y": 1,
        "transparent": 1,
        "color": null,
        "material_name": null,
        "font_name": "Abel",
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
        "position": 87,
        "masked": false,
        "masked_layers": []
      }
    ],
    "tags": []
  }
}
=end

  def update
    find_or_initialize_work
    @work.update!(work_params)
    @work.finish! if params[:finish].to_b
    render 'api/v3/works/show', locals: { include_layers: true }
  end

  private

  def find_or_initialize_work
    @work = Work.find_by!(uuid: params[:uuid])
    log_with_current_user @work
    return if @work.user == current_user
    if @work.user != current_user && @work.user.guest? && !current_user.guest?
      @work.update(user: current_user)
    else
      fail RecordNotFoundError
    end
  rescue ActiveRecord::RecordNotFound, RecordNotFoundError
    @work = current_user.works.new(uuid: params[:uuid],
                                   user: current_user,
                                   application: current_application)
    log_with_current_user @work
  end

  def work_params
    params.permit(:name, :model_id, :spec_id, :cover_image, :cover_image_aid, :perform_destroy_previews,
                  layers_attributes: layers_params)
  end

  def layers_params
    [:id, :mask_id,
     :layer_type,
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
     :position]
  end
end
