class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :aasm_state
      t.string :ship_code
      t.integer :express_id
      t.datetime :shipped_at

      t.timestamps
    end
  end
end
