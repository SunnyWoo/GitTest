class AddMemoToBillingProfile < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :memo, :hstore
  end
end
