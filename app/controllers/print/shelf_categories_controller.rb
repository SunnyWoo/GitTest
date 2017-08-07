class Print::ShelfCategoriesController < PrintController
  def new
    @category = ShelfCategory.new
  end

  def create
    @category = current_factory.shelf_categories.new(category_params)
    if @category.save
      redirect_to :back, notice: 'add category success'
    else
      redirect_to :back, notice: 'fail'
    end
  end

  private

  def category_params
    params.require(:shelf_category).permit(:name, :description)
  end
end
