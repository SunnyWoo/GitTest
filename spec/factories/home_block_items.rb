# == Schema Information
#
# Table name: home_block_items
#
#  id         :integer          not null, primary key
#  block_id   :integer
#  image      :string(255)
#  href       :string(255)
#  image_meta :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :home_block_item do
    block { build(:home_block) }
    href 'http://commandp.dev'
    after(:create) do |object|
      t = object.translations.build(locale: 'en')
      t.title = 'this is title'
      t.subtitle = 'this is subtitle'
      t.pic = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')
      t.save
    end
  end
end
