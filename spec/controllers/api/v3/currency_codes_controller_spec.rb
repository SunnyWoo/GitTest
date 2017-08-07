require 'rails_helper'

RSpec.describe Api::V3::CurrencyCodesController, :api_v3, type: :controller do
  describe '#show' do
    Given(:ip) { '127.0.0.1' }
    Given(:china_ip) { '180.76.3.151' }
    Given(:country_code) { 'TW' }
    before { allow(controller).to receive(:remote_ip).and_return(ip) }

    context 'get show', signed_in: :normal do
      context 'when use request.remote_ip' do
        before { allow(controller).to receive(:current_country_code).and_return(country_code) }
        When { get :show, access_token: access_token }
        Then { response.status == 200 }
        And {
          response.body == { ip: ip,
                             currency_code: 'TWD',
                             currency_list: CurrencyType::COUNTRY_CURRENCY_MAPPING }.to_json
        }
      end

      context 'when params[:remote_ip]' do
        When { get :show, access_token: access_token, remote_ip: china_ip }
        Then { response.status == 200 }
        And {
          response.body == { ip: china_ip,
                             currency_code: 'CNY',
                             currency_list: CurrencyType::COUNTRY_CURRENCY_MAPPING }.to_json
        }
      end
    end
  end
end
