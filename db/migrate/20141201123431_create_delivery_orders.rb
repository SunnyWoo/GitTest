class CreateDeliveryOrders < ActiveRecord::Migration
  def change
    create_table :delivery_orders do |t|
      t.belongs_to :spec
      t.string :order_no
      t.integer :print_item_ids, array: true, null: false, default: []
      t.string :state, index: true

      t.timestamps
    end
  end
end
