class UpdateChildCoupon < ActiveRecord::Migration
  def change
    Coupon.where.not(parent_id: nil, condition: %w(none shipping_fee simple rules)).update_all(condition: 'simple')
  end
end
