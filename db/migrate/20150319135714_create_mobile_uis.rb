class CreateMobileUis < ActiveRecord::Migration
  def change
    create_table :mobile_uis do |t|
      t.string :title
      t.string :description
      t.integer :template
      t.integer :device_type
      t.string :image
      t.integer :priority, default: 1
      t.date :start_at
      t.date :end_at
      t.boolean :is_enabled, default: false
      t.timestamps
    end
  end
end
