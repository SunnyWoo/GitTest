class AddSourceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :application_id, :integer
  end
end
