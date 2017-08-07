class ChangeBillingProfileColumn < ActiveRecord::Migration
  def up
    change_column :billing_profiles, :address, :text
  end

  def down
    change_column :billing_profiles, :address, :string
  end
end
