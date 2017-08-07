# == Schema Information
#
# Table name: standardized_works
#
#  id                :integer          not null, primary key
#  uuid              :string(255)
#  user_id           :integer
#  user_type         :string(255)
#  model_id          :integer
#  name              :string(255)
#  slug              :string(255)
#  aasm_state        :string(255)
#  price_tier_id     :integer
#  featured          :boolean          default(FALSE), not null
#  print_image       :string(255)
#  image_meta        :json
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  impressions_count :integer          default(0)
#  cradle            :integer          default(0)
#  bought_count      :integer          default(0)
#  content           :text
#  variant_id        :integer
#

FactoryGirl.define do
  factory :standardized_work do
    sequence(:uuid) { SecureRandom.uuid }
    user
    product { create(:product_model) }
    sequence(:name) { |n| "The Great Work ##{n}" }

    trait :with_order_image do
      after(:build) do |work|
        work.previews << build(:preview, key: 'order-image', work: work)
      end
    end

    trait :published do
      aasm_state 'published'
    end

    trait :with_reviews do
      after(:create) do |standardized_work|
        2.times do
          create(:review, work: standardized_work)
        end
      end
    end

    trait :with_iphone6_model do
      published
      product { create :iphone6_product_model }
    end

    trait :with_ipad_air2_model do
      published
      product { create :ipad_air2_product_model }
    end
  end
end
