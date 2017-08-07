# == Schema Information
#
# Table name: bdevent_products
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  product_id :integer
#  image      :string(255)
#  info       :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :bdevent_product do
    product { create :product_model }
    bdevent { create :bdevent }
    image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    title 'BB8, get the bloody map away from here!'
  end
end
