class AddProductCodeToArchivedWork < ActiveRecord::Migration
  def change
    add_column :archived_works, :product_code, :string
  end
end
