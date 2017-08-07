# == Schema Information
#
# Table name: mobile_page_previews
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string
#  title          :string
#  country_code   :string
#  begin_at       :datetime
#  close_at       :datetime
#  page_type      :integer
#  contents       :json             default({})
#  is_enabled     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :mobile_page_preview do
    sequence(:key) { |n| "preview_key#{n}" }
    sequence(:title) { |n| "preview_title#{n}" }
    begin_at Time.zone.yesterday
    close_at Time.zone.tomorrow
    page_type 'campaign_subject'
    is_enabled true
    country_code 'TW'
  end
end
