class AddApprovedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :approved_at, :datetime
  end
end
