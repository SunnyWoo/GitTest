class ProductCraftCell < Cell::Rails
  def list
    @product_crafts = ProductCraft.includes(products: [category: :translations]).all
    render
  end
end
