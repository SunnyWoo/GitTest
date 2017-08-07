class AddCoverImageToWorks < ActiveRecord::Migration
  def change
    add_column :works, :cover_image, :string
  end
end
