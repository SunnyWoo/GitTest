class AddEmbeddedCouponToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :embedded_coupon, :json
  end
end
