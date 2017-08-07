class CreateCouponRules < ActiveRecord::Migration
  def change
    create_table :coupon_rules do |t|
      t.belongs_to :coupon, index: true
      t.string :condition
      t.integer :threshold_id
      t.integer :product_model_ids, default: [], array: true
      t.integer :designer_ids, default: [], array: true
      t.integer :product_category_ids, default: [], array: true
      t.text :work_gids, default: [], array: true
      t.integer :quantity

      t.timestamps
    end

    Coupon.root.where.not(condition: %w(none shipping_fee)).find_each do |coupon|
      coupon.coupon_rules.create(condition: coupon.condition,
                                 threshold_id: coupon.threshold_id,
                                 product_model_ids: coupon.product_model_ids,
                                 designer_ids: coupon.designer_ids,
                                 product_category_ids: coupon.product_category_ids,
                                 work_gids: coupon.work_gids,
                                 quantity: 1
                                )
      coupon.update_column(:condition, 'simple')
    end
  end

  class CouponRule < ActiveRecord::Base
    belongs_to :coupon
  end

  class Coupon < ActiveRecord::Base
    has_many :coupon_rules
    scope :root, -> { where(parent_id: nil) }
  end
end
