class AddColumnCheckPaidAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :check_paid_at, :datetime
  end
end
