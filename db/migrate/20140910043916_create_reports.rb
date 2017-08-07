class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :order_id
      t.integer :user_id
      t.string  :user_role
      t.integer :order_item_num
      t.integer :price
      t.integer :coupon_price
      t.integer :shipping_fee
      t.string  :country_code
      t.string  :platform
      t.date    :date
      t.timestamps
    end
  end
end
