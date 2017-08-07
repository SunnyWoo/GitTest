class AddAddressNameToBillingProfiles < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :address_name, :string
  end
end
