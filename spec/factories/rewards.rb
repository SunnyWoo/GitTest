# == Schema Information
#
# Table name: rewards
#
#  id          :integer          not null, primary key
#  order_no    :string           not null
#  phone       :string
#  coupon_code :string
#  avatar      :string
#  cover       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :reward do
    order_no { create(:order).order_no }
    coupon_code { create(:coupon).code }
    avatar { test_jpg }
    cover { test_jpg }
  end
end
