class AddTmpImageColumnsToWorkAndLayer < ActiveRecord::Migration
  def change
    add_column :works, :cover_image_processing, :boolean
    add_column :works, :order_image_processing, :boolean
    add_column :works, :print_image_processing, :boolean
    add_column :layers, :image_processing, :boolean
    add_column :layers, :filtered_image_processing, :boolean
    add_column :works, :cover_image_tmp, :string
    add_column :works, :order_image_tmp, :string
    add_column :works, :print_image_tmp, :string
    add_column :layers, :image_tmp, :string
    add_column :layers, :filtered_image_tmp, :string
  end
end
