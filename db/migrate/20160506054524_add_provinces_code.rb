class AddProvincesCode < ActiveRecord::Migration
  def change
    add_column :provinces, :code, :string, limit: 2
    add_index :provinces, :code
  end
end
