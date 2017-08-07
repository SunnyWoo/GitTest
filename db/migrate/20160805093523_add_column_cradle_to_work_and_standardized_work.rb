class AddColumnCradleToWorkAndStandardizedWork < ActiveRecord::Migration
  def change
    add_column :works, :cradle, :integer, default: 0
    add_column :standardized_works, :cradle, :integer, default: 0
  end
end
