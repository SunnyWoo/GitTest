class ChangePromotions < ActiveRecord::Migration
  def up
    add_column :promotions, :level, :integer
    add_column :promotion_references, :price_tier_id, :integer
    change_column :adjustments, :target, :integer, null: true
  end

  def down
    remove_column :promotions, :level
    remove_column :promotion_references, :price_tier_id, :integer
    change_column :adjustments, :target, :integer, null: false
  end
end
