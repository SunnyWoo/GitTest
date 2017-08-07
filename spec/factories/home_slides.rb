# == Schema Information
#
# Table name: home_slides
#
#  id         :integer          not null, primary key
#  slide      :string(255)
#  is_enabled :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  title      :text
#  link       :string(255)
#  template   :integer          default(0)
#  desc       :hstore
#  background :string(255)
#  priority   :integer          default(1)
#  set        :string(255)
#

FactoryGirl.define do
  factory :home_slide do
    set { HomeSlide::AVAILABLE_SETS.sample }
    after(:build) do |object|
      object.translations.build(locale: 'en')
      object.translations.first.slide = fixture_file_upload("spec/photos/test.jpg", "image/jpeg")
    end
  end
end
