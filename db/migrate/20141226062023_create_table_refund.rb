class CreateTableRefund < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.integer :order_id, index: true
      t.string :refund_no
      t.float :amount
      t.string :note
      t.timestamps
    end
  end
end
