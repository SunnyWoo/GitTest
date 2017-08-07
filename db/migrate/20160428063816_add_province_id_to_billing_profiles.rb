class AddProvinceIdToBillingProfiles < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :province_id, :integer
  end
end
