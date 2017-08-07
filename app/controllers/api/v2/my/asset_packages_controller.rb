=begin
@apiDefine NeedAuth
@apiParam {String} auth_token 使用者登入用 auth_token
=end
=begin
@apiDefine AssetPackageResponse
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "asset_package": {
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
    }
  }
=end
class Api::V2::My::AssetPackagesController < ApiV2Controller
  before_action :authenticate_required!
=begin
@api {get} /api/my/asset_packages Get available favorited asset packages
@apiUse NeedAuth
@apiUse AssetPackagesResponse
@apiVersion 2.0.0
@apiGroup My/AssetPackages
@apiName GetMyAssetPackages
=end
  def index
    @packages = current_user.asset_packages.available
    render 'api/v3/asset_packages/index'
    fresh_when(etag: @packages)
  end

=begin
@api {post} /api/my/asset_packages/:id Add asset packages to favorited
@apiUse NeedAuth
@apiUse AssetPackageResponse
@apiVersion 2.0.0
@apiGroup My/AssetPackages
@apiName AddMyAssetPackages
=end
  def create
    @asset_package = asset_packages.find(params[:id])
    if @current_user.asset_packages.exclude? @asset_package
      current_user.asset_packages << @asset_package
      @asset_package.count_download
    end
    render 'api/v3/asset_packages/show'
  end

=begin
@api {delete} /api/my/asset_packages/:id Remove asset packages from favorited
@apiUse NeedAuth
@apiUse AssetPackageResponse
@apiVersion 2.0.0
@apiGroup My/AssetPackages
@apiName RemoveMyAssetPackages
=end
  def destroy
    @asset_package = asset_packages.find(params[:id])
    current_user.asset_packages.delete(@asset_package)
    render 'api/v3/asset_packages/show'
  end

  private

  def asset_packages
    AssetPackage.available.in_country(current_country_code)
  end
end
