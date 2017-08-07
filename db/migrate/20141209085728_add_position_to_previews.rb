class AddPositionToPreviews < ActiveRecord::Migration
  def change
    add_column :previews, :position, :integer
  end
end
