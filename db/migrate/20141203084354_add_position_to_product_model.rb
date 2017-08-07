class AddPositionToProductModel < ActiveRecord::Migration
  def up
    add_column :product_models, :position, :integer
    ProductCategory.all.each_with_index do |pc|
      pc.models.each_with_index do |p,i|
        p.update_attribute(:position, i+1)
      end
    end
  end

  def down
    remove_column :product_models, :position
  end

  class ProductCategory < ActiveRecord::Base
    has_many :models, class_name: 'ProductModel', foreign_key: :category_id
  end
end
