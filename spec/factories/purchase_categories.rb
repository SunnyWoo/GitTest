# == Schema Information
#
# Table name: purchase_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :purchase_category, class: 'Purchase::Category' do
    name 'mugs'
  end
end
