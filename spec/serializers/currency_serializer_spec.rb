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

require 'spec_helper'

describe CurrencySerializer do
  it 'works' do
    currency = create(:currency)
    json = JSON.parse(CurrencySerializer.new(currency).to_json)
    expect(json).to eq({
      'currency' => {
        'name' => currency.name,
        'code' => currency.code,
        'price' => currency.price,
      }
    })
  end
end
