class AddColumnDescriptionToPriceTier < ActiveRecord::Migration
  def change
    add_column :price_tiers, :description, :string
  end
end
