# == Schema Information
#
# Table name: masks
#
#  id            :integer          not null, primary key
#  material_name :string(255)
#  image         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  image_meta    :json
#

FactoryGirl.define do
  factory :mask do
    sequence(:material_name) { |n| "material#{n}" }
  end
end
