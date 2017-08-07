# == Schema Information
#
# Table name: product_categories
#
#  id               :integer          not null, primary key
#  key              :string(255)
#  available        :boolean          default(FALSE), not null
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  category_code_id :string(255)
#  image            :string(255)
#  positions        :json             default(#<ProductCategory::Positions:0x007ff2747e00e0 @ios=1, @android=1, @website=1>)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_category do
    sequence(:key) { |n| "product_category_#{n}" }
    sequence(:name) { |n| "Name_#{n}" }
    available false

    trait :with_image do
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end
  end
end
