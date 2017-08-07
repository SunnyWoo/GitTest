class AddColumnCountryCodeAndTimeZoneToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :country_code, :string
    add_column :devices, :timezone, :string
  end
end
