# == Schema Information
#
# Table name: previews
#
#  id           :integer          not null, primary key
#  work_id      :integer
#  key          :string(255)
#  image        :string(255)
#  image_meta   :text
#  high_quality :boolean          default(FALSE), not null
#  created_at   :datetime
#  updated_at   :datetime
#  position     :integer
#  work_type    :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :preview do
    image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    work
    sequence(:key) { |n| "Jedi_#{n}" }
  end
end
