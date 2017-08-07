class AddMaskIdToLayer < ActiveRecord::Migration
  def change
    add_column :layers, :mask_id, :integer
  end
end
