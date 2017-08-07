# == Schema Information
#
# Table name: works
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cover_image             :string(255)
#  work_type               :integer          default(1)
#  finished                :boolean          default(FALSE)
#  feature                 :boolean          default(FALSE)
#  uuid                    :string(255)
#  print_image             :string(255)
#  model_id                :integer
#  artwork_id              :integer
#  image_meta              :json
#  slug                    :string(255)
#  impressions_count       :integer          default(0)
#  ai                      :string(255)
#  pdf                     :string(255)
#  price_tier_id           :integer
#  attached_cover_image_id :integer
#  template_id             :integer
#  deleted_at              :datetime
#  user_type               :string(255)
#  user_id                 :integer
#  application_id          :integer
#  product_template_id     :integer
#  cradle                  :integer          default(0)
#  share_text              :text
#  variant_id              :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :work do
    transient do
      # 可用 price_table: {'TWD' => 900} 建立對應的貨幣以及價格資料
      price_table nil
    end
    name 'work name'
    description 'description do  ... '
    product { create(:product_model) }
    user
    price_tier { build(:price_tier, prices: price_table) if price_table }

    after(:create) do |work|
      work.previews.create(key: 'order-image', image: test_jpg)
    end

    trait :without_previews do
      after(:create) do |work|
        work.previews.delete_all
      end
    end

    trait :with_cover_image do
      cover_image { test_jpg }
    end

    trait :is_public do
      work_type 'is_public'
    end

    trait :redeem do
      work_type 'redeem'
    end

    trait :featured do
      featured true
    end

    factory :featured_work do
      is_public
      featured
    end

    trait :with_iphone6_model do
      is_public
      product { create :iphone6_product_model }
    end

    trait :with_ipad_air2_model do
      is_public
      product { create :ipad_air2_product_model }
    end

    trait :with_mug_model do
      is_public
      product { create :mug_product_model }
    end

    trait :with_unavailable_model do
      product { create :unavailable_product_model }
    end

    trait :with_reviews do
      after(:create) do |work|
        2.times do
          create(:review, work: work)
        end
      end
    end

    trait :with_special_price do
      is_public
      product { create :iphone6_product_model }
      price_tier { build(:price_tier, prices: { 'USD' => 10, 'TWD' => 300 } ) }
    end
  end
end
