class AddColumnToDefaultToMobileUis < ActiveRecord::Migration
  def change
    add_column :mobile_uis, :default, :boolean, default: false
  end
end
