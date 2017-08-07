class CreatePurchaseDurations < ActiveRecord::Migration
  def change
    create_table :purchase_durations do |t|
      t.string :year
      t.string :month

      t.timestamps
    end

    add_index :purchase_durations, [:year, :month], unique: true
  end
end
