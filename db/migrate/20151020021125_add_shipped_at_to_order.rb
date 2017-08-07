class AddShippedAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipped_at, :datetime
    Order.finish.find_each { |order| order.update(shipped_at: order.updated_at) }
  end
end
