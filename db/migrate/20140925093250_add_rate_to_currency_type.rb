class AddRateToCurrencyType < ActiveRecord::Migration
  def change
    add_column :currency_types, :rate, :float, default: 1
  end
end
