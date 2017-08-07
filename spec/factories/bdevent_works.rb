# == Schema Information
#
# Table name: bdevent_works
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  work_id    :integer
#  work_type  :string(255)
#  info       :json
#  image      :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :bdevent_work do
    work { create :work }
    bdevent { create :bdevent }
    image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    title 'The Stormtrooper from First Order'
  end
end
