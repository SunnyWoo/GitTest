class CreateChangePriceHistories < ActiveRecord::Migration
  def change
    create_table :change_price_histories do |t|
      t.integer :change_price_event_id
      t.integer :changeable_id
      t.string :changeable_type
      t.string :price_type
      t.integer :original_price_tier_id
      t.integer :target_price_tier_id
      t.timestamps
    end

    add_index :change_price_histories, :change_price_event_id
    add_index :change_price_histories, [:changeable_id, :changeable_type], name: 'by_changeable'
  end
end
