class RemoveOrderImageFormWork < ActiveRecord::Migration
  def change
    remove_column :works, :order_image
    remove_column :archived_works, :order_image
  end
end
