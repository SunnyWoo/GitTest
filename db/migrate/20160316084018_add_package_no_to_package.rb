class AddPackageNoToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :package_no, :string
    add_index :packages, :package_no, unique: true
  end
end
