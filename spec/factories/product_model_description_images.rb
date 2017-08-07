# == Schema Information
#
# Table name: product_model_description_images
#
#  id         :integer          not null, primary key
#  product_id :integer
#  image      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :product_model_description_image, class: 'ProductModel::DescriptionImage' do
    image { fixture_file_upload('spec/photos/big_image.jpg', 'image/jpeg') }
  end
end
