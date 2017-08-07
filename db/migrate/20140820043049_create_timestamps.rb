class CreateTimestamps < ActiveRecord::Migration
  def change
    create_table :timestamps do |t|
      t.date :date
      t.integer :timestamp_no, limit: 8
      t.timestamps
    end
    add_index :timestamps, :date
  end
end
