class AddShippingWayToBillingProfiles < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :shipping_way, :integer, default: 0
  end
end
