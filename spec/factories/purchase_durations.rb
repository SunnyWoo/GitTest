# == Schema Information
#
# Table name: purchase_durations
#
#  id         :integer          not null, primary key
#  year       :string(255)
#  month      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :purchase_duration, class: 'Purchase::Duration' do
    year '2016'
    month '1'
  end
end
