# == Schema Information
#
# Table name: product_models
#
#  id                                        :integer          not null, primary key
#  name                                      :string(255)
#  description                               :text
#  created_at                                :datetime
#  updated_at                                :datetime
#  available                                 :boolean          default(FALSE)
#  slug                                      :string(255)
#  category_id                               :integer
#  key                                       :string(255)
#  dir_name                                  :string(255)
#  placeholder_image                         :string(255)
#  price_tier_id                             :integer
#  design_platform                           :json
#  customize_platform                        :json
#  customized_special_price_tier_id          :integer
#  material                                  :string(255)
#  weight                                    :float
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE), not null
#  factory_id                                :integer
#  extra_info                                :json
#  aasm_state                                :string(255)
#  positions                                 :json             default(#<ProductModel::Positions:0x007ff27a813688 @ios=1, @android=1, @website=1>)
#  remote_key                                :string(255)
#  watermark                                 :string(255)
#  print_image_mask                          :string(255)
#  craft_id                                  :integer
#  spec_id                                   :integer
#  material_id                               :integer
#  code                                      :string(255)
#  external_code                             :string(255)
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#  profit_id                                 :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :product_model do
    transient do
      # 可用 price_table: {'TWD' => 900} 建立對應的貨幣以及價格資料
      price_table('USD' => 99.9, 'TWD' => 2999, 'JPY' => 12_000, 'CNY' => 600, 'HKD' => 500)
      customized_special_price_table nil
    end
    category { create(:product_category) }
    sequence(:key) { |n| "iphone_#{n}_case" }
    sequence(:name) { |n| "ProductModelName#{n + 7}" }
    description { "#{name} case" }
    short_name 'my short name'
    price_tier { build(:price_tier, prices: price_table) }
    customized_special_price_tier do
      build(:price_tier, prices: customized_special_price_table) if customized_special_price_table
    end
    available true
    design_platform 'website' => 'true'
    customize_platform 'website' => 'true'

    # spec columns
    width 1.5
    height 1.5
    dpi 300
    background_image { test_jpg }
    overlay_image { test_jpg }
    shape 'rectangle'
    alignment_points 'none'

    factory_id { create(:factory).id }

    factory :iphone6_product_model do
      name 'iPhone 6'
      price_table('JPY' => 2500, 'USD' => 29.00, 'HKD' => 120, 'TWD' => 500)
      available true
    end

    factory :unavailable_product_model do
      name 'unavailable'
      price_table('JPY' => 2500, 'USD' => 29.00, 'HKD' => 120, 'TWD' => 500)
      available false
    end

    factory :ipad_air2_product_model do
      name 'iPad air 2'
      price_table('JPY' => 2500, 'USD' => 29.00, 'HKD' => 120, 'TWD' => 500)
      available true
    end

    factory :mug_product_model do
      key 'mug'
      name 'Mug'
      price_table('JPY' => 1200, 'USD' => 15.00, 'HKD' => 60, 'TWD' => 250)
      available true
    end

    trait :enable_white do
      enable_white true
    end

    trait :available_for_staff do
      available true
      aasm_state :staff
    end

    trait :available_for_customer do
      available true
      aasm_state :customer
    end

    trait :unavailable do
      available false
    end

    trait :with_des_images do
      after(:create) do |product|
        2.times do
          create :product_model_description_image, product: product
        end
      end
    end
  end
end
