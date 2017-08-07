class Admin::ProductsController < AdminController
  def index
    @categories = ProductModel.includes(:category).group_by(&:category).to_a

    respond_to do |f|
      f.html
      f.json { render 'admin/products/index' }
    end
  end
end
