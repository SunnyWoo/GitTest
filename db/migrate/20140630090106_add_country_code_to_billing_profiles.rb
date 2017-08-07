class AddCountryCodeToBillingProfiles < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :country_code, :string
  end
end
