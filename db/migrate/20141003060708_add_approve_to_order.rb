class AddApproveToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :approve, :boolean, default: true
  end
end
