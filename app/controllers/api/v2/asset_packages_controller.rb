=begin
@apiDefine AssetPackagesResponse
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "asset_packages": [{
      "id": 28,
      "icon": "http://...",
      "designer_id": 1,
      "name": "Diablo 3",
      "description": "Sucks",
      "available": true,
      "begin_at": "2015-03-02",
      "end_at": "2199-12-31",
      "countries": ["US"],
      "designer": { "id": 1, "display_name": "First Designer" },
      "links": {
        "assets": {
          "url": "http://...",
          "accept": "application/commandp.v2"
        }
      }
    }]
  }
=end
class Api::V2::AssetPackagesController < ApiV2Controller
=begin
@api {get} /api/asset_packages Get available asset packages
@apiUse AssetPackagesResponse
@apiVersion 2.0.0
@apiGroup AssetPackages
@apiName GetAssetPackages
=end
  def index
    @packages = AssetPackage.available.in_country(current_country_code)
    render 'api/v3/asset_packages/index'
    fresh_when(etag: @packages)
  end
end
