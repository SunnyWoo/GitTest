class AddColumnBoughtCountToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :bought_count, :integer, default: 0
    add_index :product_templates, :bought_count
  end
end
