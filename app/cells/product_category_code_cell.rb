class ProductCategoryCodeCell < Cell::Rails
  def list
    @category_codes = ProductCategoryCode.includes(category: :translations).all
    render
  end
end
