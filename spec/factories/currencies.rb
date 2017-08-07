# == Schema Information
#
# Table name: currencies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  code             :string(255)
#  price            :float
#  product_model_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  coupon_id        :integer
#  payable_id       :integer
#  payable_type     :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :currency do
    name 'U.S. Dollar'
    code 'USD'
    price 99.9
    # payable { create(:product_model) }
  end
end
