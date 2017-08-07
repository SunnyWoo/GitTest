class Print::ImpositionsController < PrintController
  include ImpositionFinder

  before_action :find_model, except: %w(index upload)

  def index
    @categories = ProductCategory.all.includes(:products)
  end

  def new
    authorize Imposition, :create?
    if params[:type].blank?
      select_type
    else
      find_imposition_class
      @imposition = @imposition_class.new(product: @model)
    end
  end

  def select_type
    render :select_type
  end

  def create
    authorize Imposition, :create?
    find_imposition_class
    @imposition = @imposition_class.new(product: @model)
    if @imposition.update(imposition_params)
      redirect_to print_impositions_path
    else
      render :new
    end
  end

  def edit
    authorize Imposition, :update?
    @imposition = @model.imposition || @model.build_imposition
  end

  def update
    authorize Imposition, :update?
    @imposition = @model.imposition || @model.build_imposition
    if @imposition.update(imposition_params)
      redirect_to print_impositions_path
    else
      render :edit
    end
  end

  def upload
    authorize Imposition, :upload?
    @model = ProductModel.find(params[:model_id])
    @model.enqueue_imposite_and_upload
    render nothing: true
  end

  def destroy
    authorize Imposition, :destory?
    @model.imposition.try(:destroy)
    redirect_to print_impositions_path
  end
end
