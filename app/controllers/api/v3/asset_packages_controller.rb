class Api::V3::AssetPackagesController < ApiV3Controller
  before_action :doorkeeper_authorize!
=begin
@api {get} /api/asset_packages/:id Get the asset_package info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup AssetPackages
@apiName ShowAssetPackage
@apiParam {Integer} id asset_package's id
@apiSuccessExample {json} Response-Example:
{
  "asset_package": {
    "id": 2,
    "name": "封存",
    "name_translations": {
      "zh-TW": "封存",
      "zh-CN": "封存",
      "zh-HK": "封存",
      "en": "first",
      "ja": ""
    },
    "description": "拉拉拉拉",
    "description_translations": {
      "zh-TW": "拉拉拉拉",
      "zh-CN": "拉拉啦拉拉",
      "zh-HK": "拉拉拉拉",
      "en": "lalalala",
      "ja": ""
    },
    "available": true,
    "designer_id": 1,
    "category_id": 1,
    "begin_at": "2015-09-23",
    "end_at": "2199-12-31",
    "countries": [
      "TW"
    ],
    "position": 1,
    "downloads_count": 7,
    "category_name": "星期一",
    "icon": null,
    "designer": {
      "id": 1,
      "display_name": "陳勇嘉"
    }
  }
}
=end
  def show
    @package = AssetPackage.find params[:id]
  end
end
