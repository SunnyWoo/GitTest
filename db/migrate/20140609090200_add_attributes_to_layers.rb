class AddAttributesToLayers < ActiveRecord::Migration

  def change
    add_column :layers, :position, :integer
    add_column :layers, :creator_name, :string
    add_column :layers, :filter, :string
  end

end
