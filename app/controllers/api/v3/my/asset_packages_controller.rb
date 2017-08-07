class Api::V3::My::AssetPackagesController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_package, except: :index

=begin
@api {get} /api/my/asset_packages/ Get the current_user's asset_packages
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MyAssetPackages
@apiName MyAssetPackageIndex
@apiSuccessExample {json} Response-Example:
{
  "asset_packages": [
    {
      "id": 20,
      "name": "暴風兵軍團",
      "name_translations": {
        "zh-TW": "暴風兵軍團",
        "zh-CN": "",
        "zh-HK": "",
        "en": "Stormtrooper",
        "ja": ""
      },
      "description": "測試排序",
      "description_translations": {
        "zh-TW": "測試排序",
        "zh-CN": "",
        "zh-HK": "",
        "en": "...",
        "ja": ""
      },
      "available": true,
      "designer_id": 1,
      "category_id": null,
      "begin_at": "2015-10-28",
      "end_at": "2016-10-31",
      "countries": [
        "JP",
        "TW"
      ],
      "position": 9,
      "downloads_count": 1,
      "category_name": null,
      "icon": null,
      "designer": {
        "id": 1,
        "display_name": "暴風兵"
      }
    }
  ],
  "meta": {
    "asset_packages_count": 1
  }
}
=end

  def index
    @packages = current_user.asset_packages.available
  end

=begin
@api {post} /api/my/asset_packages/:id add asset_package to the current_user
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MyAssetPackages
@apiName MyAssetPackagePost
@apiParam {String} id asset_package's id
@apiSuccessExample {json} Response-Example:
{
  "asset_package": {
    "id": 20,
    "name": "暴風兵軍團",
    "available": true,
    "designer_id": 1,
    "category_id": null,
    "begin_at": "2015-10-28",
    "end_at": "2016-10-31",
    "countries": [
      "JP",
      "TW"
    ],
    "downloads_count": 0,
    "icon": null
  }
}
=end

  def create
    if current_user.asset_packages.exclude? @package
      current_user.asset_packages << @package
      @package.count_download
    end
    render 'api/v3/asset_packages/show'
  end

=begin
@api {delete} /api/my/asset_packages/:id remove asset_package from the current_user
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MyAssetPackages
@apiName MyAssetPackageDestroy
@apiParam {String} id asset_package's id
@apiSuccessExample {json} Response-Example:
{
  "asset_package": {
    "id": 20,
    "name": "暴風兵軍團",
    "available": true,
    "designer_id": 1,
    "category_id": null,
    "begin_at": "2015-10-28",
    "end_at": "2016-10-31",
    "countries": [
      "JP",
      "TW"
    ],
    "downloads_count": 0,
    "icon": null
  }
}
=end

  def destroy
    current_user.asset_packages.destroy @package
    render 'api/v3/asset_packages/show'
  end

  protected

  def find_package
    @package = AssetPackage.available.in_country(current_country_code).find params[:id]
  end
end
