class UpdateOrderApprovedAt < ActiveRecord::Migration
  def change
    Order.find_each do |order|
      next if order.approved_activity.blank?
      order.update_column(:approved_at, order.approved_activity.created_at)
    end
  end
end
