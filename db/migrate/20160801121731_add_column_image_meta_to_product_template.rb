class AddColumnImageMetaToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :image_meta, :json
  end
end
