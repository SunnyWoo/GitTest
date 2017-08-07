class Api::V3::AssetPackageCategoriesController < ApiV3Controller
  before_action :doorkeeper_authorize!
=begin
@api {get} /api/asset_package_categories/:id Get the asset_package_category info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup AssetPackageCategories
@apiName ShowAssetPackageCategory
@apiParam {String} id asset_package_category's id
@apiSuccessExample {json} Response-Example:
{
  "asset_package_category": {
    "id": 2,
    "name": "壕門",
    "available": true,
    "packages_count": 3,
    "downloads_count": 18,
    "packages": [
      {
        "id": 12,
        "name": "我是副市長的測試，你們這些ci看著辦",
        "available": false,
        "designer_id": 2,
        "category_id": 2,
        "begin_at": "2015-10-22",
        "end_at": "2199-12-31",
        "countries": [
          "JP",
          "TW",
          "US"
        ],
        "downloads_count": 0,
        "icon": "http://commandp.dev/uploads/asset_package/icon/12/739_n.jpg?v=144550"
      }
    ]
  }
}
=end
  def show
    @category = AssetPackageCategory.find params[:id]
  end
end
