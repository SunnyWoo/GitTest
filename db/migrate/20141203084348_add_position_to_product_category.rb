class AddPositionToProductCategory < ActiveRecord::Migration
  def up
    add_column :product_categories, :position, :integer

    ProductCategory.all.each_with_index do |p,i|
      p.update_attribute(:position, i+1)
    end
  end

  def down
    remove_column :product_categories, :position
  end
end
