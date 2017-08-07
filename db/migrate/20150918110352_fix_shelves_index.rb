class FixShelvesIndex < ActiveRecord::Migration
  def change
    remove_index :shelves, [:serial, :section]
    add_index :shelves, [:serial, :section, :factory_id], unique: true
  end
end
