class Admin::CpResourcesController < AdminController
  before_action :find_cp_resource, only: %i(show edit update)

  def index
    @cp_resources = CpResource.page(params[:page]).order(id: :desc)
  end

  def show
  end

  def edit
  end

  def update
    if @cp_resource.update(cp_resource_params)
      redirect_to admin_cp_resources_path
    else
      render :edit
    end
  end

  def new
    @form = Admin::UpdateAssetPackageFileForm.new
  end

  def create
    cp = CpResource.create(version: CpResource.new_version)
    options = params[:admin_update_asset_package_file_form].merge(version: cp.version)
    @form = Admin::UpdateAssetPackageFileForm.new(options)
    if @form.upload
      cp.publish!
      redirect_to admin_cp_resources_path, notice: '檔案更新完成'
    else
      render :new
    end
  end


  private

  def find_cp_resource
    @cp_resource = CpResource.find(params[:id])
  end

  def cp_resource_params
    params.require(:cp_resource).permit(:version, :aasm_state)
  end
end
