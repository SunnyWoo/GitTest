class CreatePromotionRules < ActiveRecord::Migration
  def change
    create_table :promotion_rules do |t|
      t.integer "promotion_id"
      t.string  "condition"
      t.integer "threshold_id"
      t.integer "product_model_ids",    default: [], array: true
      t.integer "designer_ids",         default: [], array: true
      t.integer "product_category_ids", default: [], array: true
      t.text    "work_gids",            default: [], array: true
      t.integer "bdevent_id"
      t.integer "quantity", default: 1
      t.timestamps
    end

    add_index :promotion_rules, :promotion_id
  end
end
