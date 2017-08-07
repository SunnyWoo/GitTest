class CreateProductOptionTypes < ActiveRecord::Migration
  def change
    create_table :product_option_types do |t|
      t.integer :product_id
      t.integer :option_type_id
      t.integer :position

      t.timestamps null: false
    end

    add_index :product_option_types, :product_id
    add_index :product_option_types, [:product_id, :option_type_id], unique: true
  end
end
