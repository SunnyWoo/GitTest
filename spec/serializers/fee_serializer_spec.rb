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

require 'spec_helper'

describe FeeSerializer do
  it 'works' do
    fee = create(:fee)
    json = JSON.parse(FeeSerializer.new(fee).to_json)
    expect(json).to eq({
      'fee' => {
        'name' => fee.name,
        'currencies' => fee.currencies.map { |currency|
          {
            'name' => currency.name,
            'code' => currency.code,
            'price' => currency.price,
          }
        }
      }
    })
  end

  it 'get 2 times' do
    fee = create(:fee, name: 'aaa')
    json = JSON.parse(FeeSerializer.new(fee).to_json)
    expect(json).to eq({
      'fee' => {
        'name' => fee.name,
        'currencies' => fee.currencies.map { |currency|
          {
            'name' => currency.name,
            'code' => currency.code,
            'price' => currency.price,
          }
        }
      }
    })

    fee = create(:fee, name: 'bbb')
    json = JSON.parse(FeeSerializer.new(fee).to_json)
    expect(json['fee']['name']).not_to eq('aaa')
    expect(json).to eq({
      'fee' => {
        'name' => fee.name,
        'currencies' => fee.currencies.map { |currency|
          {
            'name' => currency.name,
            'code' => currency.code,
            'price' => currency.price,
          }
        }
      }
    })
  end
end
