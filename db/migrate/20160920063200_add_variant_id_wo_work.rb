class AddVariantIdWoWork < ActiveRecord::Migration
  def change
    add_column :works, :variant_id, :integer
    add_column :archived_works, :variant_id, :integer
    add_column :archived_standardized_works, :variant_id, :integer
    add_column :standardized_works, :variant_id, :integer

    add_index :works, :variant_id
    add_index :archived_works, :variant_id
    add_index :archived_standardized_works, :variant_id
    add_index :standardized_works, :variant_id
  end
end
