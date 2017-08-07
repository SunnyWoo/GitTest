class RemoveMarketings < ActiveRecord::Migration
  def change
    drop_table :marketings
  end
end
