class Admin::ProductCategoriesController < AdminController
  include TagCreator
  before_action :category_codes, only: [:new, :edit]
  def index
    @categories = ProductCategory.all

    respond_to do |f|
      f.html
      f.json
    end
  end

  def new
    @category = ProductCategory.new
  end

  def create
    set_tag_ids(:category)
    @category = ProductCategory.new(category_params)
    if @category.save
      render
    else
      render :new
    end
  end

  def show
    @category = ProductCategory.find(params[:id])
  end

  def edit
    @category = ProductCategory.find(params[:id])
  end

  def update
    set_tag_ids(:category)
    @category = ProductCategory.find(params[:id])
    if @category.update(category_params)
      render :create
    else
      render :edit
    end
  end

  def update_position
    @category = ProductCategory.find(params[:id])
    if @category.set_platform_position(params[:platform], params[:position])
      render json: { status: 'ok', message: 'Update Success!' }
    else
      render json: { status: 'error', message: @category.errors.full_messages }
    end
  end

  private

  def category_params
    params.require(:category).permit(ProductCategory.globalize_attribute_names + [:key, :available, :category_code_id, :image, tag_ids: []])
  end

  def category_codes
    @category_codes = ProductCategoryCode.all.pluck(:code, :id)
  end
end
