class Admin::ProductModelsController < Admin::ResourcesController
  include TagCreator
  before_action :product_codes, only: [:new, :edit]
  before_action :load_import_product_log, only: :import

  def index
    q = params[:q] || { s: 'created_at desc' }
    @search = ProductModel.ransack(q)
    @resources = @search.result.includes([:translations, category: :translations])
    @resources = @resources.page(params[:page]) unless params[:page] == 'all'

    respond_to do |f|
      f.html
      f.json { render json: @resources, each_serializer: ProductModelSerializer }
    end
  end

  def new
    super
    @resource.build_currencies_set
  end

  def create
    set_tag_ids(:product_model)
    super
  end

  def edit
    super
    @resource.build_missing_currencies_set
  end

  def update
    set_tag_ids(:product_model)
    @product_model = ProductModel.find(params[:id])
    model_params = admin_permitted_params.product_model
    model_params[:design_platform] ||= {}
    model_params[:customize_platform] ||= {}
    log_with_current_admin @product_model
    if @product_model.update_attributes(model_params)
      if params[:redirect_to_path]
        redirect_to URI.parse(params[:redirect_to_path]).path
      else
        flash[:notice] = "#{model_name} (#{@product_model.class.primary_key} = #{@product_model.to_param}) 更新成功!"
        redirect_to action: :index
      end
      flash[:alert] = @product_model.warning
    else
      @resource = @product_model
      flash[:alert] = @resource.errors.full_messages
      render :edit
    end
  end

  def sort
    @product_categories = ProductCategory.all
  end

  def update_position
    @product_model = ProductModel.find(params[:id])
    if @product_model.set_platform_position(params[:platform], params[:position])
      render json: { status: 'ok', message: 'Update Success!' }
    else
      render json: { status: 'error', message: @product_model.errors.full_messages }
    end
  end

  def export
    json = Product::ExportService.new(params[:ids].split(',')).execute if params[:ids]
    respond_to do |format|
      format.html { render nothing: true }
      format.json do
        send_data json, filename: "export_product_models_#{Time.zone.now}.json"
      end
    end
  end

  def import
    if params[:import_file].present?
      file = params[:import_file].read
      service = Product::BackgroundImportService.new(json: file, email: current_admin.email)
      service.execute
      flash[:notice] = "已加入排成，完成後會寄出 Email 通知 To: #{current_admin.email}"
    end
  end

  private

  def product_codes
    @specs = ProductSpec.select_collections
    @crafts = ProductCraft.select_collections
    @materials = ProductMaterial.select_collections
  end

  def load_import_product_log
    if params[:key].present?
      log_key = "#{params[:key]}:logs"
      log = $redis.get(log_key)
      @logs = log.present? ? JSON.parse(log) : []
    end
  end
end
