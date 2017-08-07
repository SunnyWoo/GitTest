class UpdatePendingOrderCheckPaidAtByItsCreatedAt < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute "UPDATE orders SET check_paid_at = created_at + interval '3 days' WHERE orders.aasm_state = 'pending' AND (orders.payment NOT IN ('neweb/atm', 'neweb/mmk'))"
  end
end
