class AddSettingsToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :settings, :hstore, default: {}
  end
end
