class CreateChangePriceEvents < ActiveRecord::Migration
  def change
    create_table :change_price_events do |t|
      t.integer :operator_id
      t.integer :target_ids, default: [], array: true
      t.integer :price_tier_id
      t.string :target_type
      t.timestamps
    end
  end
end
