class AddAttachmentIdsToLayers < ActiveRecord::Migration
  def change
    add_reference :layers, :attached_image, index: true
    add_reference :layers, :attached_filtered_image, index: true
  end
end
