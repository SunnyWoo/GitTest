class Admin::AssetPackagesController < AdminController
  def index
    scope = %w(ready on_board off_board unavailable).include?(params[:scope]) ? params[:scope] : 'available'
    @packages = AssetPackage.send(scope).with_translations(I18n.locale).ransack(params[:q]).result.all
    respond_to do |f|
      f.html
      f.json { render 'api/v3/asset_packages/index' }
    end
  end

  def create
    @form = AssetPackageForm.new(create_params)
    if @form.save
      @package = @form.asset_package
      render 'api/v3/asset_packages/show'
    else
      render json: @form.errors, status: :unprocessable_entity
    end
  end

  def show
    @package = AssetPackage.find(params[:id])
    render 'api/v3/asset_packages/show'
  end

  def update
    @package = AssetPackage.find(params[:id])
    if @package.update(update_params)
      render 'api/v3/asset_packages/show'
    else
      render json: @package.errors, status: :unprocessable_entity
    end
  end

  def update_position
    @asset_package = AssetPackage.find(params[:id])
    if @asset_package.insert_at(params[:position].to_i)
      render json: { message: 'Update Success!' }, status: :ok
    else
      render json: { message: @asset_package.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit_file
    @form = Admin::UpdateAssetPackageFileForm.new
  end

  def update_file
    @form = Admin::UpdateAssetPackageFileForm.new(params[:admin_update_asset_package_file_form])
    if @form.upload
      redirect_to edit_file_admin_asset_packages_path, notice: '檔案更新完成'
    else
      render :edit_file
    end
  end

  private

  def create_params
    params.permit(:file)
  end

  def update_params
    params.require(:asset_package).permit(:designer_id,
                                          :category_id,
                                          :available, :begin_at, :end_at,
                                          :insert_position,
                                          countries: [],
                                          name_translations: I18n.available_locales,
                                          description_translations: I18n.available_locales)
  end
end
