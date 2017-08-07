# == Schema Information
#
# Table name: purchase_price_tiers
#
#  id          :integer          not null, primary key
#  category_id :integer
#  count_key   :integer
#  price       :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :purchase_price_tier, class: 'Purchase::PriceTier' do
    category { create :purchase_category }
    count_key 0
    price 100.11
  end
end
