class RenameColumnDisablePreviewsCreatedByPrintInProductmodel < ActiveRecord::Migration
  def change
    rename_column :product_models, :disable_previews_created_by_print, :create_order_image_by_cover_image
  end
end
