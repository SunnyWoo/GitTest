# == Schema Information
#
# Table name: order_items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  itemable_id      :integer
#  itemable_type    :string(255)
#  quantity         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timestamp_no     :integer
#  print_at         :datetime
#  aasm_state       :string(255)
#  pdf              :string(255)
#  prices           :json
#  original_prices  :json
#  discount         :decimal(8, 2)
#  remote_id        :integer
#  delivered        :boolean          default(FALSE)
#  deliver_complete :boolean          default(FALSE)
#  remote_info      :json
#  selling_prices   :json
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_item do
    quantity 1
    itemable { create(:work) }

    trait :with_public_work do
      itemable { create(:work, :is_public) }
    end

    trait :with_standardized_work do
      itemable { create(:standardized_work, aasm_state: 'published') }
    end

    trait :with_redeem_work do
      itemable { create(:work, :redeem) }
    end

    trait :with_sublimated do
      aasm_state :sublimated
      order { create(:paid_order) }
    end

    trait :with_qualified do
      aasm_state :qualified
      order { create(:paid_order) }
    end

    trait :with_onboard do
      aasm_state :onboard
      order { create(:paid_order) }
    end

    trait :with_delivering do
      aasm_state :delivering
      order { create(:paid_order) }
    end

    factory :order_item_for_pricing, class: OrderItem::ForPricing do
      aasm_state :pending
    end

    factory :iphone6_order_item do
      itemable { create(:work, :with_iphone6_model) }
    end
  end
end
