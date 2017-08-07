# == Schema Information
#
# Table name: asset_package_categories
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  available       :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  packages_count  :integer          default(0)
#  downloads_count :integer          default(0)
#

FactoryGirl.define do
  factory :asset_package_category do
    available true
    after(:build) do |category|
      category.translations.build locale: :en, name: 'Star Wars'
      category.translations.build locale: :'zh-TW', name: '星星戰爭們'
    end
  end
end
