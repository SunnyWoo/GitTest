class Api::V3::FontsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/fonts Get all fonts file
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Fonts
@apiName GetFonts
@apiSuccessExample {json} Response-Example:
 {
    "fonts": [
      {
        "name": "Abel",
        "url": "http://commandp.dev/assets/Abel-Regular.ttf"
      },
      {
        "name": "Amatic",
        "url": "http://commandp.dev/assets/Amatic-Bold.ttf"
      }
    ]
  }
=end
  def index
    render json: { fonts: fonts }, status: :ok
  end

  protected

  def fonts
    CommandP::Resources.fonts.map do |font|
      {
        name: font.name,
        url:  view_context.asset_path(font.file)
      }
    end
  end
end
