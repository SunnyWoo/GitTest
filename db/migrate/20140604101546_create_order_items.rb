class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :order, index: true
      t.belongs_to :itemable, polymorphic: true
      t.integer :quantity

      t.timestamps
    end
    add_index :order_items, [:itemable_id, :itemable_type]
    drop_table :work_order_relationships
  end
end
