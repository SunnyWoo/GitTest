class AddProductModelsAndApplyTargetToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :product_model_ids, :integer, array: true, default: []
    add_column :coupons, :apply_target, :string

    Coupon.update_all(apply_target: 'order')
  end

  class Coupon < ActiveRecord::Base
  end
end
