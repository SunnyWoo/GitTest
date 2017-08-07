class AddProductCodeToArchivedStandardizedWork < ActiveRecord::Migration
  def change
    add_column :archived_standardized_works, :product_code, :string
  end
end
