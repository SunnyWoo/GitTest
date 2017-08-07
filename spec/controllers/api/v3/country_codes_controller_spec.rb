require 'rails_helper'

RSpec.describe Api::V3::CountryCodesController, :api_v3, type: :controller do
  describe '#show' do
    Given(:ip) { '127.0.0.1' }
    Given(:china_ip) { '180.76.3.151' }
    Given(:country_code) { 'TW' }
    before { allow(controller).to receive(:remote_ip).and_return(ip) }

    context 'get show', signed_in: :normal do
      context 'when use request.remote_ip' do
        before { allow(controller).to receive(:country_code_by_ip).with(ip).and_return(country_code) }
        When { get :show, access_token: access_token }
        Then { response.status == 200 }
        And {
          response.body == { ip: ip, country_code: country_code }.to_json
        }
      end

      context 'when overwrites X-Forwarded-For' do
        let(:ip) { '127.0.0.5' }
        it 'returns client ip' do
          allow(controller).to receive(:country_code_by_ip).with(ip).and_return(country_code)
          @request.headers['X-Forwarded-For'] = "#{ip}, 127.0.0.10"
          get :show, access_token: access_token
          expect(response.body).to eq({ ip: ip, country_code: country_code }.to_json)
        end
      end

      context 'when params[:remote_ip]' do
        When { get :show, access_token: access_token, remote_ip: china_ip }
        Then { response.status == 200 }
        And {
          response.body == { ip: china_ip, country_code: 'CN' }.to_json
        }
      end
    end
  end
end
