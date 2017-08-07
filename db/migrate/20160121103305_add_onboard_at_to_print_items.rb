class AddOnboardAtToPrintItems < ActiveRecord::Migration
  def change
    add_column :print_items, :onboard_at, :datetime
  end
end
