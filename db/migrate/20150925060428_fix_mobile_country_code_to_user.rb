class FixMobileCountryCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :mobile_country_code, :string, limit: 16
    add_index :users, [:mobile, :mobile_country_code], unique: true
  end
end
