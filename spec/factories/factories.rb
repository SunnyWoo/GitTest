# == Schema Information
#
# Table name: factories
#
#  id            :integer          not null, primary key
#  code          :string(255)
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  contact_email :text
#  locale        :string(255)
#

FactoryGirl.define do
  factory :factory do
    sequence(:name) { |n| "commandp#{n}" }
    sequence(:code) { |n| "commandp#{n}" }
    sequence(:contact_email) { |n| "yoyo_#{n}@commandp.com" }
    locale 'zh-TW'
    factory :factory_with_dropbox do
      after(:create) do |factory|
        create(:dropbox_omniauth, owner: factory)
      end
    end

    after(:create) do |factory|
      create(:ftp_gateway, factory: factory)
    end
  end
end
