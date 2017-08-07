require 'spec_helper'

describe Api::V3::DevicesController, :api_v3, type: :controller do
  before(:all) { Device.skip_callback(:save, :after, :update_endpoint_arn) }
  after(:all) { Device.set_callback(:save, :after, :update_endpoint_arn) }

  let!(:device) { create(:device) }

  describe '#create' do
    it 'return status 200' do
      token = SecureRandom.hex
      put :update, token: token,
                   os_version: 'iOS99',
                   device_type: 'iOS',
                   country_code: 'TW',
                   timezone: 'Taipei',
                   getui_client_id: SecureRandom.hex
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/devices/show')
    end

    context 'without os_version' do
      it 'return status 400' do
        token = SecureRandom.hex
        put :update, token: token,
                     device_type: 'iOS',
                     country_code: 'TW',
                     timezone: 'Taipei'
        expect(response.status).to eq(422)
        expect(response_json['code']).to eq('RecordInvalidError')
        expect(response.body).to include('Os version')
      end
    end

    context 'without device_type' do
      it 'return status 400' do
        token = SecureRandom.hex
        put :update, token: token,
                     os_version: 'iOS99',
                     country_code: 'TW',
                     timezone: 'Taipei'
        expect(response.status).to eq(422)
        expect(response_json['code']).to eq('RecordInvalidError')
        expect(response.body).to include('Device type')
      end
    end

    context 'with is not a valid device_type' do
      it 'return status 400' do
        token = SecureRandom.hex
        put :update, token: token,
                     os_version: 'iOS99',
                     device_type: 'Windows',
                     country_code: 'TW',
                     timezone: 'Taipei'
        expect(response.status).to eq(400)
        expect(response_json['code']).to eq('DeviceError')
        expect(response.body).to include('device_type')
      end
    end
  end

  describe '#update' do
    it 'return status 200' do
      put :update, token: device.token,
                   os_version: 'iOS100',
                   device_type: 'iOS',
                   getui_client_id: SecureRandom.hex
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/devices/show')
      expect(device.getui_client_id).not_to be_nil
    end
  end
end
