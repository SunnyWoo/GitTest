class AddColumnProfitToProductModelAndProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :special_price_tier_id, :integer
    add_index :product_templates, :special_price_tier_id

    add_column :product_models, :profit_id, :integer
    add_index :product_models, :profit_id
  end
end
