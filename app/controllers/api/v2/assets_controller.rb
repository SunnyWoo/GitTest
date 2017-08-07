class Api::V2::AssetsController < ApiV2Controller
=begin
@api {get} /api/assets Get assets
@apiGroup Assets
@apiName GetAssets
@apiVersion 2.0.0
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "assets": [{
      "id": 1,
      "uuid": "f4484efe-c222-11e4-b931-0c4de9c8b9e5",
      "type": "sticker", // "sticker", "coating", or "foiling"
      "image": "http://...",
      "raster": "http://...",
      "vector": "http://...",
      "colorizable": false
    }]
  }
=end
  def index
    @asset_package = AssetPackage.find(params[:asset_package_id])
    @assets = @asset_package.assets
    render 'api/v3/assets/index'
    fresh_when(etag: [@asset_package, @assets])
  end
end
