class CreateDailyRecords < ActiveRecord::Migration
  def change
    create_table :daily_records do |t|
      t.string :type
      t.json :data
      t.timestamps null: false
    end
  end
end
