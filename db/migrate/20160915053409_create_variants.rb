class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.integer :product_id

      t.timestamps null: false
    end

    add_index :variants, :product_id
  end
end
