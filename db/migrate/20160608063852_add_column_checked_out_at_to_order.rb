class AddColumnCheckedOutAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :checked_out_at, :datetime
  end
end
