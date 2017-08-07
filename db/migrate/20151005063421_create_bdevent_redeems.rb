class CreateBdeventRedeems < ActiveRecord::Migration
  def change
    create_table :bdevent_redeems do |t|
      t.string :code
      t.integer :bdevent_id
      t.integer :parent_id
      t.integer :children_count, default: 0
      t.integer :usage_count, default: 0
      t.integer :usage_count_limit, default: -1
      t.integer :product_model_ids, array: true, default: []
      t.integer :order_ids, array: true, default: []
      t.boolean :is_enabled, default: true
      t.timestamps
    end

    add_index :bdevent_redeems, :code
    add_index :bdevent_redeems, :bdevent_id
    add_index :bdevent_redeems, :parent_id
  end
end
