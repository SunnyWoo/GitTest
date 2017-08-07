class CreatePromotionReferences < ActiveRecord::Migration
  def change
    create_table :promotion_references do |t|
      t.integer :promotion_id
      t.integer :promotable_id
      t.string :promotable_type
      t.timestamps
    end

    add_index :promotion_references, :promotion_id
    add_index :promotion_references, [:promotable_id, :promotable_type]
  end
end
