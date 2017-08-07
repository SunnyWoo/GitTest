class CreateProductTemplates < ActiveRecord::Migration
  def change
    create_table :product_templates do |t|
      t.belongs_to :product_model, index: true
      t.belongs_to :store, index: true
      t.belongs_to :price_tier, index: true
      t.string :name
      t.string :placeholer_image
      t.string :template_image
      t.integer :template_type
      t.string :aasm_state
      t.json :settings
      t.timestamps
    end
  end
end
