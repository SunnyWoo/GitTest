# == Schema Information
#
# Table name: email_banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  is_default :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :email_banner do
    name 'Default banner'
    file { fixture_file_upload("spec/photos/test.jpg", "image/jpeg") }
    starts_at Time.zone.now - 1.days
    ends_at Time.zone.now + 10.days
    is_default false
  end
end
