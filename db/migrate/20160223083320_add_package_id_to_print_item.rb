class AddPackageIdToPrintItem < ActiveRecord::Migration
  def change
    add_column :print_items, :package_id, :integer
    add_index :print_items, :package_id
  end
end
