class Admin::PurchaseCategoriesController < AdminController
  before_action :find_category, only: [:edit, :update]

  def index
    @categories = Purchase::Category.includes(:price_tiers, product_references: [product: :translations]).all
  end

  def new
    @category = Purchase::Category.new
  end

  def create
    @category = Purchase::Category.new(category_params)
    if @category.save
      @category.update_attributes(product_ids)
      redirect_to admin_purchase_categories_path, notice: 'success'
    else
      redirect_to :new
    end
  end

  def edit
  end

  def update
    if @category.update_attributes(category_params.merge(product_ids))
      redirect_to admin_purchase_categories_path, notice: 'success'
    else
      redirect_to :edit
    end
  end

  private

  def find_category
    @category = Purchase::Category.find(params[:id])
  end

  def category_params
    params.require(:purchase_category).permit(:name, price_tiers_attributes: [:id, :count_key, :price, :_destroy])
  end

  def product_ids
    params.require(:purchase_category).slice(:product_ids).permit!
  end
end
