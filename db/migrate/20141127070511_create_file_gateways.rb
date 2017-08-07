class CreateFileGateways < ActiveRecord::Migration
  def change
    create_table :file_gateways do |t|
      t.string  :type
      t.integer :factory_id
      t.hstore  :connect_info

      t.timestamps
    end
  end
end
