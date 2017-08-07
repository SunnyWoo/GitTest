# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fee do
    transient do
      # 可用 price_table: {'TWD' => 900} 建立對應的貨幣以及價格資料
      price_table('USD' => 150, 'TWD' => 4500)
    end

    name "ShipCost"
    after(:create) do |fee, evaluator|
      evaluator.price_table.each do |currency_code, price|
        CurrencyType.where(code: currency_code).first_or_create(name: currency_code)
        currencie = fee.currencies.find_or_initialize_by(code: currency_code)
        currencie.name = currency_code
        currencie.price = price
        currencie.save
      end
    end
  end
end
