class CreateWaybillRoutes < ActiveRecord::Migration
  def change
    create_table :waybill_routes do |t|
      t.integer :order_id
      t.string :route_no
      t.string :mail_no
      t.datetime :accept_time
      t.string :accept_address
      t.string :remark
      t.string :op_code
      t.timestamps
    end
  end
end
