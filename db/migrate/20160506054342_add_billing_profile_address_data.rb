class AddBillingProfileAddressData < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :address_data, :json
  end
end
