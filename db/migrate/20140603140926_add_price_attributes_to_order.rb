class AddPriceAttributesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :price, :float
    add_column :orders, :currency, :string
  end
end
