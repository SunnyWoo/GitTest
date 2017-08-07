# == Schema Information
#
# Table name: assets
#
#  id          :integer          not null, primary key
#  package_id  :integer
#  available   :boolean          default(FALSE), not null
#  uuid        :string(255)
#  type        :string(255)
#  raster      :string(255)
#  vector      :string(255)
#  image_meta  :json
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  colorizable :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :asset do
    package { build(:asset_package) }
    type 'sticker'
  end
end
