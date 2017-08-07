class Admin::AssetPackageIconsController < ApplicationController
  def create
    @asset_package = AssetPackage.find(params[:asset_package_id])
    @asset_package.update(icon: params[:file])
    @asset_package.reload
    render json: { icon: @asset_package.icon.thumb.url }
  end
end
