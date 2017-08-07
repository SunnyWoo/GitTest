# == Schema Information
#
# Table name: archived_works
#
#  id                  :integer          not null, primary key
#  original_work_id    :integer
#  artwork_id          :integer
#  model_id            :integer
#  cover_image         :string(255)
#  print_image         :string(255)
#  fixed_image         :string(255)
#  image_meta          :json
#  created_at          :datetime
#  updated_at          :datetime
#  slug                :string(255)
#  uuid                :string(255)
#  ai                  :string(255)
#  pdf                 :string(255)
#  prices              :json
#  user_type           :string(255)
#  user_id             :integer
#  application_id      :integer
#  name                :string(255)
#  product_code        :string(255)
#  product_template_id :integer
#  variant_id          :integer
#

include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :archived_work do
    product { create(:product_model) }
    cover_image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    user { create :user }
  end
end
