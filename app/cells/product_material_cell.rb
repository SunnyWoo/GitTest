class ProductMaterialCell < Cell::Rails
  def list
    @product_materials = ProductMaterial.includes(products: [category: :translations]).all
    render
  end
end
