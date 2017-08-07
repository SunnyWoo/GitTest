# == Schema Information
#
# Table name: currency_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  rate        :float            default(1.0)
#  precision   :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :currency_type do
    name 'U.S. Dollar'
    code 'USD'
    rate 30
    precision 0

    factory :twd_currency_type do
      name 'Taiwan New Dollar'
      code 'TWD'
      rate 1
      precision 0
    end

    factory :usd_currency_type do
      name 'U.S. Dollar'
      code 'USD'
      rate 30
      precision 2
    end

    factory :cny_currency_type do
      name 'CNY'
      code 'CNY'
      rate 5
      precision 2
    end
  end
end
