class CreateOptionValues < ActiveRecord::Migration
  def change
    create_table :option_values do |t|
      t.integer :option_type_id
      t.string :name
      t.string :presentation
      t.integer :position

      t.timestamps null: false
    end

    add_index :option_values, :option_type_id
    add_index :option_values, [:option_type_id, :name], unique: true
  end
end
