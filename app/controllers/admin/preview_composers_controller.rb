class Admin::PreviewComposersController < AdminController
  before_action :find_model

  def index
    @preview_composers = @model.preview_composers.where.not(key: Preview::STORE_PREVIEW_KEYS)
  end

  def new
    if params[:type].blank?
      select_type
    else
      find_preview_composer_class
      @preview_composer = @preview_composer_class.new(product: @model)
    end
  end

  def select_type
    render :select_type
  end

  def create
    find_preview_composer_class
    @preview_composer = @preview_composer_class.new(product: @model)
    if @preview_composer.update(create_preview_composer_params)
      redirect_to admin_product_model_preview_composers_path(@model)
    else
      render :new
    end
  end

  def edit
    @preview_composer = @model.preview_composers.find(params[:id])
  end

  def update
    @preview_composer = @model.preview_composers.find(params[:id])
    if @preview_composer.update(update_preview_composer_params(@preview_composer))
      respond_to do |f|
        f.html { redirect_to admin_product_model_preview_composers_path(@model) }
        f.json { render nothing: true }
      end
    else
      respond_to do |f|
        f.html { render :edit }
        f.json { render nothing: true }
      end
    end
  end

  def rebuild
    PreviewsRebuilder.perform_async(@model.id)
    render nothing: true
  end

  private

  def find_model
    @model = ProductModel.find(params[:product_model_id])
  end

  def find_preview_composer_class
    @preview_composer_class = PreviewComposer.const_get(params[:type])
  end

  def create_preview_composer_params
    params.require(:preview_composer)
      .permit([:key, :available, :position] + find_preview_composer_class.available_params)
  end

  def update_preview_composer_params(preview_composer)
    params.require(:preview_composer)
      .permit([:key, :available, :position] + preview_composer.class.available_params)
  end
end
