class AddShipCodeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :ship_code, :string
  end
end
