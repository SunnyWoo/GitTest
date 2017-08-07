class CreatePrintHistories < ActiveRecord::Migration
  def change
    create_table :print_histories do |t|
      t.integer :print_item_id
      t.integer :timestamp_no, limit: 8
      t.string :print_type
      t.string :reason
      t.datetime :prepare_at
      t.datetime :print_at
      t.datetime :onboard_at
      t.datetime :sublimated_at

      t.timestamps
    end

    PrintItem.find_each do |print_item|
      attributes = { print_type: 'print',
                     timestamp_no: print_item.timestamp_no,
                     prepare_at: print_item.prepare_at,
                     print_at: print_item.print_at,
                     onboard_at: print_item.onboard_at,
                     sublimated_at: print_item.sublimated_at }
      print_item.print_histories.create(attributes)
    end
  end
end
