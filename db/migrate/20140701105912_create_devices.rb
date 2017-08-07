class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.belongs_to :user, index: true
      t.string :token
      t.text :detail
      t.string :os_version
      t.integer :device_type

      t.timestamps
    end
  end
end
