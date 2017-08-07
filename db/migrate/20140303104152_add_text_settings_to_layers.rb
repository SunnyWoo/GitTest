class AddTextSettingsToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :text_alignment, :string
    add_column :layers, :text_spacing_x, :integer
    add_column :layers, :text_spacing_y, :integer
  end
end
