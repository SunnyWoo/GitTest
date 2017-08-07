class AddProductCategoryIdsToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :product_category_ids, :integer, array: true, default: []
  end
end
