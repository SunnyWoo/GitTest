class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :order_no, null: false
      t.string :phone, null: false
      t.string :coupon_code
      t.string :avatar
      t.string :cover
      t.timestamps null: false
    end

    add_index :rewards, [:order_no, :phone]
    add_index :rewards, :coupon_code
  end
end
