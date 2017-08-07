# == Schema Information
#
# Table name: archived_standardized_works
#
#  id               :integer          not null, primary key
#  uuid             :string(255)
#  slug             :string(255)
#  original_work_id :integer
#  user_id          :integer
#  user_type        :string(255)
#  model_id         :integer
#  name             :string(255)
#  price_tier_id    :integer
#  featured         :boolean
#  print_image      :string(255)
#  image_meta       :json
#  created_at       :datetime
#  updated_at       :datetime
#  product_code     :string(255)
#  variant_id       :integer
#

include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :archived_standardized_work do
    name 'archived standardized work'
    product { create(:product_model) }
    user { create :user }
  end
end
