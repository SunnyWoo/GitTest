class AddDescriptionToTempShelf < ActiveRecord::Migration
  def change
    add_column :temp_shelves, :description, :string
    remove_column :temp_shelves, :section, :string
  end
end
