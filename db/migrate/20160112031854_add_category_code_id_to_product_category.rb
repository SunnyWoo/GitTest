class AddCategoryCodeIdToProductCategory < ActiveRecord::Migration
  def change
    add_column :product_categories, :category_code_id, :string
  end
end
