class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :name, null: false, unique: true
      t.text :description
      t.string :type, null: false
      t.integer :aasm_state
      t.integer :rule
      t.json :rule_parameters
      t.integer :targets
      t.datetime :begins_at
      t.datetime :ends_at
      t.timestamps
    end

    add_index :promotions, :type
    add_index :promotions, :aasm_state
    add_index :promotions, [:type, :aasm_state]
  end
end
