class CreateOptionValueVariants < ActiveRecord::Migration
  def change
    create_table :option_value_variants do |t|
      t.integer :variant_id
      t.integer :option_value_id

      t.timestamps null: false
    end

    add_index :option_value_variants, :variant_id
    add_index :option_value_variants, [:variant_id, :option_value_id], unique: true
  end
end
