class CreatePriceTiers < ActiveRecord::Migration
  def change
    create_table :price_tiers do |t|
      t.integer :tier
      t.json :prices

      t.timestamps
    end
  end
end
