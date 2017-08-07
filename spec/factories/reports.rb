# == Schema Information
#
# Table name: reports
#
#  id                    :integer          not null, primary key
#  order_id              :integer
#  user_id               :integer
#  user_role             :string(255)
#  order_item_num        :integer
#  price                 :integer
#  coupon_price          :integer
#  shipping_fee          :integer
#  country_code          :string(255)
#  platform              :string(255)
#  date                  :date
#  created_at            :datetime
#  updated_at            :datetime
#  subtotal              :integer
#  refund                :integer
#  total                 :integer
#  shipping_fee_discount :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    user { create :user }
    order { create :order }
    order_item_num 3
    price 999
    coupon_price 10
    shipping_fee 150
    country_code 'TW'
    platform 'iOS'
    date Date.today
  end
end
