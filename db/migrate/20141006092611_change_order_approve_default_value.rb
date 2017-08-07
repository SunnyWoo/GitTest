class ChangeOrderApproveDefaultValue < ActiveRecord::Migration
  def change
    change_column :orders, :approve, :boolean, default: false
  end
end
