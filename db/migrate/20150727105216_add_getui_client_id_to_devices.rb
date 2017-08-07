class AddGetuiClientIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :getui_client_id, :string
  end
end
