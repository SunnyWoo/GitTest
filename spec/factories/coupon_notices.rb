# == Schema Information
#
# Table name: coupon_notices
#
#  id         :integer          not null, primary key
#  coupon_id  :integer
#  notice     :string(255)
#  available  :boolean
#  platform   :json
#  region     :json
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :coupon_notice do
    coupon { create :coupon, title: 'for_test' }
    notice '感谢您注册为噗印会员，您的专属5元优惠码 %{coupon_code}，下单立减5元。噗印中国官网上线，全场包邮大促！'
    available true
    platform 'mobile' => true, 'email' => false
    region 'china' => true, 'global' => false
  end
end
