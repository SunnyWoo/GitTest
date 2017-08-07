# == Schema Information
#
# Table name: bdevent_images
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  locale     :string(255)
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :bdevent_image do
    bdevent { create(:bdevent) }
    locale I18n.locale
    file { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
  end
end
