class AddTimestampNoToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :timestamp_no, :bigint
    add_index :order_items, :timestamp_no
    add_column :order_items, :print_at, :datetime
    add_column :order_items, :aasm_state, :string
  end
end
