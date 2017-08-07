class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :title
      t.string :code, index: true
      t.datetime :expired_at
      t.boolean :is_used, default: false
      t.integer :order_id, index: true

      t.timestamps
    end
  end
end
