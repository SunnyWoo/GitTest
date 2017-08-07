module Admin::ProductHelper
  def link_to_product(product)
    link_to(product.name, edit_admin_product_model_path(product))
  end
end
