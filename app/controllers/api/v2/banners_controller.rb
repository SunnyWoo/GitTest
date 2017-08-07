class Api::V2::BannersController < ApiV2Controller
=begin
@api {get} /api/banners Get available banners
@apiVersion 2.0.0
@apiGroup Banners
@apiName GetBanners
@apiSuccessExample {json} Success-Response:
  {
    "banners": [
      {
        "id": 1,
        "name": "good news",
        "deeplink": "commandp://...",
        "image": {
          "url": "http://commandp.dev/1/77b452e8ca9a5bdcf29274db.jpg?v=1417683292"
        },
        "platforms": ["iOS", "Android"],
        "url": "http://commandp.com/blah"
      }
    ]
  }
=end
  def index
    @banners = Banner.available.in_country(current_country_code)
    render 'api/v3/banners/index'
    fresh_when(etag: @banners)
  end
end
