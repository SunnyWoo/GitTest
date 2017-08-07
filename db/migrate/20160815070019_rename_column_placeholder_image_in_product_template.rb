class RenameColumnPlaceholderImageInProductTemplate < ActiveRecord::Migration
  def change
    rename_column :product_templates, :placeholer_image, :placeholder_image
  end
end
