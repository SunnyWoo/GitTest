class RemoveColumnDeviceTypeFromMobileUi < ActiveRecord::Migration
  def change
    remove_column :mobile_uis, :device_type
  end
end
