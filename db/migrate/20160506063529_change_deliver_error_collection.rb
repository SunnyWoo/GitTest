class ChangeDeliverErrorCollection < ActiveRecord::Migration
  def change
    change_column :deliver_error_collections, :cover_image_url, :text
    change_column :deliver_error_collections, :print_image_url, :text
  end
end
