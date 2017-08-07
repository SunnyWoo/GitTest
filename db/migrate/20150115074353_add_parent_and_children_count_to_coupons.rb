class AddParentAndChildrenCountToCoupons < ActiveRecord::Migration
  def change
    add_reference :coupons, :parent, index: true
    add_column :coupons, :children_count, :integer, default: 0
  end
end
