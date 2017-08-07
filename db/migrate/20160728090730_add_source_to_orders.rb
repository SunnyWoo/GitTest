class AddSourceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :source, :integer, default: 0, null: false
    add_column :orders, :channel, :string

    Order.where(payment: 'nuandao_b2b').update_all(source: 1, channel: 'nuandao')
  end
end
