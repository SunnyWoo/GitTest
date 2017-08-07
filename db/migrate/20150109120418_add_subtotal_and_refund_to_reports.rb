class AddSubtotalAndRefundToReports < ActiveRecord::Migration
  def change
    add_column :reports, :subtotal, :integer
    add_column :reports, :refund, :integer
  end
end
