class AddLocaleToBatchFlow < ActiveRecord::Migration
  def change
    add_column :batch_flows, :locale, :string
  end
end
