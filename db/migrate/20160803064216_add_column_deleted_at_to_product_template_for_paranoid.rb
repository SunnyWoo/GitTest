class AddColumnDeletedAtToProductTemplateForParanoid < ActiveRecord::Migration
  def change
    add_column :product_templates, :deleted_at, :datetime
    add_index :product_templates, :deleted_at
  end
end
