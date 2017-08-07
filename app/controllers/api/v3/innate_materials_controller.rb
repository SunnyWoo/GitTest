class Api::V3::InnateMaterialsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/innate_materials Get all innate_materials
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup InnateMaterials
@apiName InnateMaterialsList
@apiSuccessExample {json} Response-Example:
  {
     "stickers": [
       {
         "url": "http://commandp.dev/assets/editor/sticker/cp_stickers_01.svg",
         "name": "cp_stickers_01"
       },
       {
         "url": "http://commandp.dev/assets/editor/sticker/cp_stickers_02.svg",
         "name": "cp_stickers_02"
       }
     ],
     "shapes": [
       {
         "url": "http://commandp.dev/assets/editor/shape/cp_shapes_37.svg",
         "name": "cp_shapes_37"
       },
       {
         "url": "http://commandp.dev/assets/editor/shape/cp_shapes_38.svg",
         "name": "cp_shapes_38"
       }
     ],
     "typographies": [
       {
         "url": "http://commandp.dev/assets/editor/typography/cp_typography_44.svg",
         "name": "cp_typography_44"
       },
       {
         "url": "http://commandp.dev/assets/editor/typography/cp_typography_45.svg",
         "name": "cp_typography_45"
       }
     ]
  }
=end
  def index
    render json: {
      lines:        editor_line_list,
      shapes:       editor_shape_list,
      stickers:     editor_sticker_list,
      textures:     editor_texture_list,
      typographies: editor_typography_list,
      frames:       editor_frame_list
    }, status: :ok
  end

  %w(line shape sticker texture typography frame).each do |attr|
    define_method "editor_#{attr}_list" do
      CommandP::Resources.send(attr.pluralize).map do |resource|
        {
          url: view_context.image_url(resource.file),
          name: resource.name
        }
      end
    end
  end
end
