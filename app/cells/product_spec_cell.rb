class ProductSpecCell < Cell::Rails
  def list
    @product_specs = ProductSpec.includes(products: [category: :translations]).all
    render
  end
end
