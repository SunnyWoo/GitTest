require 'spec_helper'

describe Address do
  Given(:data){ {} }
  Given(:value) { Address.new(data) }

  context 'address info' do
    Given(:data) { { address: 'street', city: 'Taipei', dist: 'Shushan District', zip_code: '10288', country: 'TW' } }
    Then { expect(value.address).to eq 'street' }
    And { expect(value.city).to eq 'Taipei' }
    And { expect(value.zip_code).to eq '10288' }
    And { expect(value.dist).to eq 'Shushan District' }
  end

  context 'retrieve data via dist_code=' do
    context 'TW' do
      Given(:data) { { country_code: 'TW' } }
      context 'setup city and dist by dict_code' do
        When { value.dist_code = '106' }
        Then { expect(value.city).to eq '臺北市' }
        And { expect(value.dist).to eq '大安區' }
      end
    end

    context 'CN as country' do
      Given(:data) { { country_code: 'CN' } }
      context 'setup city and dist by dict_code' do
        When { value.dist_code = '130105' }
        Then { expect(value.province).to eq '河北省' }
        And { expect(value.city).to eq '石家庄市' }
        And { expect(value.dist).to eq '新华区' }
      end
    end
  end

  describe '#to_s' do
    context 'chinese address' do
      Given(:data) { { country_code: 'TW', country: '台灣', city: '台北市', dist: '松山區', address: '南京東路五段87號', zip_code: '11391' } }
      Then { expect(value.to_s).to eq "Taiwan, Republic Of China台北市松山區南京東路五段87號11391" }
    end

    context 'non-chinese address' do
      Given(:data) { { country_code: 'US', country: 'United States', city: 'Los Angeles', state: 'CA', address: 'Santa Monica Boulevard', zip_code: '90025-4718' } }
      Then { expect(value.to_s).to eq "Santa Monica Boulevard, Los Angeles, CA, 90025-4718, United States" }
    end
  end
end
