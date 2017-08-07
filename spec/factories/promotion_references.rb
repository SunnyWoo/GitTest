# == Schema Information
#
# Table name: promotion_references
#
#  id              :integer          not null, primary key
#  promotion_id    :integer
#  promotable_id   :integer
#  promotable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  price_tier_id   :integer
#

FactoryGirl.define do
  factory :promotion_reference do
  end

  trait :product_model do
    promotion { create :promotion_for_product_model, :pay }
    promotable { create :product_model }
  end
end
