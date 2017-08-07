class RemoveCarrierwaveBackgrounder < ActiveRecord::Migration
  def change
    remove_column :layers, :image_processing
    remove_column :layers, :filtered_image_processing
    remove_column :works, :cover_image_processing
    remove_column :works, :print_image_processing
    remove_column :works, :order_image_processing

    remove_column :layers, :image_tmp
    remove_column :layers, :filtered_image_tmp
    remove_column :works, :cover_image_tmp
    remove_column :works, :print_image_tmp
    remove_column :works, :order_image_tmp
  end
end
