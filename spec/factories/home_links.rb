# == Schema Information
#
# Table name: home_links
#
#  id         :integer          not null, primary key
#  href       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :home_link do
    href "http://www.manutd.com/Splash-Page.aspx"
    position 1
    after(:build) do |home_link|
      home_link.translations.build locale: :en, name: "ManUtd"
    end
  end
end
