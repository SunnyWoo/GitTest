# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  price                 :float
#  currency              :string(255)
#  payment_id            :string(255)
#  order_no              :string(255)
#  work_state            :integer          default(0)
#  refund_id             :string(255)
#  ship_code             :string(255)
#  uuid                  :string(255)
#  coupon_id             :integer
#  payment               :string(255)
#  order_data            :hstore
#  payment_info          :json             default({})
#  approved              :boolean          default(FALSE)
#  invoice_state         :integer          default(0)
#  invoice_info          :json
#  embedded_coupon       :json
#  subtotal              :decimal(8, 2)
#  discount              :decimal(8, 2)
#  shipping_fee          :decimal(8, 2)
#  shipping_receipt      :string(255)
#  application_id        :integer
#  message               :text
#  shipped_at            :datetime
#  viewable              :boolean          default(TRUE)
#  paid_at               :datetime
#  remote_id             :integer
#  delivered_at          :datetime
#  deliver_complete      :boolean          default(FALSE)
#  remote_info           :json
#  approved_at           :datetime
#  merge_target_ids      :integer          default([]), is an Array
#  packaging_state       :integer          default(0)
#  shipping_state        :integer          default(0)
#  shipping_fee_discount :decimal(8, 2)    default(0.0)
#  flags                 :integer
#  watching              :boolean          default(FALSE)
#  invoice_required      :boolean
#  checked_out_at        :datetime
#  lock_version          :integer          default(0), not null
#  enable_schedule       :boolean          default(TRUE)
#  source                :integer          default(0), not null
#  channel               :string(255)
#  order_info            :json
#

FactoryGirl.define do
  factory :order do
    user { create :user }
    currency 'USD'
    price 0
    subtotal 0

    billing_info
    shipping_info
    payment 'paypal'

    trait :with_paypal_create do
      payment_id 'PAY-46W38094FH7689133KPXSBHQ'
    end

    trait :with_coupon do
      coupon { create(:coupon) }
    end

    trait :with_atm do
      payment 'neweb/atm'
      aasm_state :waiting_for_payment
    end

    trait :with_mmk do
      payment 'neweb/mmk'
      aasm_state :waiting_for_payment
    end

    trait :with_cash_on_delivery do
      shipping_info { create(:shipping_info) }
      payment 'cash_on_delivery'
    end

    trait :with_stripe do
      payment 'stripe'
      currency 'USD'
    end

    trait :with_pingpp_alipay do
      payment_id 'ch_jjjbzTeTeHe9PKaHyPCyLmDO'
      payment 'pingpp_alipay'
      aasm_state :paid
      price 99
      subtotal 99
      currency 'CNY'
    end

    trait :with_pingpp_wx do
      payment_id 'ch_q1eDK8S8iXn9Sq94KCSKebHS'
      payment 'pingpp_wx'
      aasm_state :paid
      price 1
      subtotal 1
      currency 'CNY'
    end

    trait :with_free do
      payment 'pingpp_alipay_qr'
      price 0
      subtotal 0
      currency 'CNY'
    end

    trait :with_redeem do
      payment 'redeem'
    end

    trait :with_nuandao_b2b do
      payment 'nuandao_b2b'
    end

    trait :with_public_work do
      order_items { [create(:order_item, :with_public_work)] }
    end

    trait :with_standardized_work do
      order_items { [create(:order_item, :with_standardized_work)] }
    end

    after(:create) do |order|
      order.order_items << create(:order_item, order: order)
    end

    factory :pending_order do
      aasm_state :pending
      after(:create) do |order|
        order.reload.calculate_price!
      end
    end

    factory :paid_order do
      aasm_state :paid
      payment_id '123456'
      after(:create) do |order|
        order.reload.calculate_price!
      end
    end

    factory :shipping_to_tw_order do
      shipping_info { create(:shipping_info, country_code: 'TW') }
    end

    trait :priced do
      after :create do |order, _evaluator|
        order.reload.calculate_price!
      end
    end

    trait :shop do
      source :shop
    end
  end
end
