class RenameProductPlaceholder < ActiveRecord::Migration
  def change
    rename_column :product_models, :product_placeholder, :placeholder_image
  end
end
