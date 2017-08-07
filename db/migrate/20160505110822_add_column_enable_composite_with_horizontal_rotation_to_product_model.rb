class AddColumnEnableCompositeWithHorizontalRotationToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :enable_composite_with_horizontal_rotation, :boolean, default: false
  end
end
