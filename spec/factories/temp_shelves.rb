# == Schema Information
#
# Table name: temp_shelves
#
#  id            :integer          not null, primary key
#  print_item_id :integer
#  serial        :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  description   :string(255)
#

FactoryGirl.define do
  factory :temp_shelf do
    print_item { create :print_item, :with_sublimated }
    serial 'serial'
  end
end
