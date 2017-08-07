class AddAttachedCoverImageToWorks < ActiveRecord::Migration
  def change
    add_reference :works, :attached_cover_image, index: true
  end
end
