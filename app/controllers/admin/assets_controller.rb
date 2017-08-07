class Admin::AssetsController < AdminController
  before_action :load_asset_package, only: :index

  def index
    @assets = @asset_package.assets
    render 'api/v3/assets/index'
  end

  def update
    @asset = Asset.find(params[:id])
    @asset.update(asset_params)
    render 'api/v3/assets/show'
  end

  private

  def load_asset_package
    @asset_package = AssetPackage.find(params[:asset_package_id])
  end

  def asset_params
    params.require(:asset).permit(:colorizable)
  end
end
