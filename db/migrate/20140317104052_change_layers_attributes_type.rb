class ChangeLayersAttributesType < ActiveRecord::Migration
  def change
    remove_column :layers, :position_x
    remove_column :layers, :position_y
    add_column :layers, :position_x, :float
    add_column :layers, :position_y, :float
    remove_column :layers, :text_spacing_x
    remove_column :layers, :text_spacing_y
    add_column :layers, :text_spacing_x, :integer
    add_column :layers, :text_spacing_y, :integer
    remove_column :layers, :text_alignment
    add_column :layers, :text_alignment, :integer
    add_column :layers, :filter_type, :integer
  end
end
