class AddFilteredImageToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :filtered_image, :string
  end
end
