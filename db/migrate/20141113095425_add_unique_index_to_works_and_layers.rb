class AddUniqueIndexToWorksAndLayers < ActiveRecord::Migration
  def change
    remove_index :works, :uuid
    add_index :works, :uuid, unique: true
    remove_index :layers, :uuid
    add_index :layers, :uuid, unique: true
  end
end
