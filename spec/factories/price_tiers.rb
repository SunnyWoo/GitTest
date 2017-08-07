# == Schema Information
#
# Table name: price_tiers
#
#  id          :integer          not null, primary key
#  tier        :integer
#  prices      :json
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :price_tier do
    tier 1
    prices { { "USD" => 10, "TWD" => 300 } }
    trait :twd_499 do
      tier 99
      prices { { "USD" => 16.7, "TWD" => 499.0, "CNY" => 99 } }
    end
    trait :twd_100 do
      tier 100
      prices { { "USD" => 3.5, "TWD" => 100.0, "CNY" => 20 } }
    end
  end
end
