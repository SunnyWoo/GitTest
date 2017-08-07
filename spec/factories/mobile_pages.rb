# == Schema Information
#
# Table name: mobile_pages
#
#  id           :integer          not null, primary key
#  key          :string(255)
#  title        :string(255)
#  begin_at     :datetime
#  close_at     :datetime
#  is_enabled   :boolean          default(FALSE)
#  contents     :json
#  created_at   :datetime
#  updated_at   :datetime
#  page_type    :integer
#  country_code :string(255)
#

FactoryGirl.define do
  factory :mobile_page do
    sequence(:key) { |n| "key#{n}" }
    sequence(:title) { |n| "title#{n}" }
    begin_at Time.zone.yesterday
    close_at Time.zone.tomorrow
    page_type 'campaign_subject'
    is_enabled true
    country_code 'TW'
  end
end
