# == Schema Information
#
# Table name: print_histories
#
#  id            :integer          not null, primary key
#  print_item_id :integer
#  timestamp_no  :integer
#  print_type    :string(255)
#  reason        :string(255)
#  prepare_at    :datetime
#  print_at      :datetime
#  onboard_at    :datetime
#  sublimated_at :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  qualified_at  :datetime
#  shipped_at    :datetime
#

FactoryGirl.define do
  factory :print_history do
    print_item { create :print_item }
    print_type 'print'

    trait :with_qualified do
      qualified_at Time.zone.now
      print_item { create :print_item, :with_qualified }
    end
  end
end
