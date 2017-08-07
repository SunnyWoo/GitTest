# == Schema Information
#
# Table name: asset_packages
#
#  id              :integer          not null, primary key
#  designer_id     :integer
#  icon            :string(255)
#  available       :boolean          default(FALSE), not null
#  begin_at        :date
#  end_at          :date
#  countries       :string(255)      default([]), is an Array
#  position        :integer
#  image_meta      :json
#  created_at      :datetime
#  updated_at      :datetime
#  category_id     :integer
#  downloads_count :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :asset_package do
    designer
    available false
    category  { create :asset_package_category }
    factory(:available_asset_package) do
      available true
      name 'A great package'
      description 'Awesome!'
      begin_at { Time.zone.today }
      end_at { Time.zone.today }
    end
  end
end
