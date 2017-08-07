# == Schema Information
#
# Table name: refunds
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  refund_no  :string(255)
#  amount     :float
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :refund do
    order { create :order }
    amount 100
  end
end
