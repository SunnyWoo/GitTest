# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  work_id    :integer
#  work_type  :string(255)
#  body       :text
#  star       :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :review do
    user
    work
    body 'lorem'
    star { rand(1..5) }
  end
end
