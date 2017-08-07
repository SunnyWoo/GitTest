class AddEmailToBillingProfile < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :email, :string
  end
end
