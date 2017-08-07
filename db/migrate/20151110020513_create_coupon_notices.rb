class CreateCouponNotices < ActiveRecord::Migration
  def change
    create_table :coupon_notices do |t|
      t.integer :coupon_id
      t.string :notice
      t.boolean :available
      t.json :platform, default: { mobile: false, email: false }
      t.json :region, default: { china: false, global: false }

      t.timestamps
    end
    return if Region.global?
    {
      newcomer_discount_5RMB: '感谢您注册为噗印会员，您的专属5元优惠码%{coupon_code}，下单立减5元。噗印中国官网上线，全场包邮大促！',
      newcomer_discount_10RMB: '感谢您注册为噗印会员，您的专属10元优惠码%{coupon_code}，订单满99立减10元。噗印中国官网上线，全场包邮大促！',
      newcomer_discount_35RMB: '感谢您注册为噗印会员，您的专属35元优惠码%{coupon_code}，订单满199立减35元。噗印中国官网上线，全场包邮大促！'
    }.each do |coupon_title, notice|
      coupon = Coupon.find_by(title: coupon_title.to_s, parent: nil)
      return Rails.logger.warn 'coupon title not found' unless coupon
      CouponNotice.create(coupon_id: coupon.id,
                          notice: notice,
                          available: true,
                          platform: { mobile: true, email: false },
                          region: { china: true, global: false })
    end
  end
end
