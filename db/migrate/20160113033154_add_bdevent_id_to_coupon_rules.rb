class AddBdeventIdToCouponRules < ActiveRecord::Migration
  def change
    add_column :coupon_rules, :bdevent_id, :integer
  end
end
