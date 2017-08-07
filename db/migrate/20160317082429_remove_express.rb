class RemoveExpress < ActiveRecord::Migration
  def change
    drop_table :expresses
    remove_column :orders, :express_id
  end
end
