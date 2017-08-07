class RemoveOrderColumnCheckPaidAt < ActiveRecord::Migration
  def change
    remove_column :orders, :check_paid_at
  end
end
