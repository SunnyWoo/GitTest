class AddStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :packaging_state, :integer, default: 0
    add_column :orders, :shipping_state, :integer, default: 0
  end
end
