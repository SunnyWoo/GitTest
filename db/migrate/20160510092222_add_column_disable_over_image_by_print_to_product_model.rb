class AddColumnDisableOverImageByPrintToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :disable_previews_created_by_print, :boolean, default: false
  end
end
