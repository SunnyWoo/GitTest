class RenameOrdersApproveToApproved < ActiveRecord::Migration
  def change
    rename_column :orders, :approve, :approved
  end
end
