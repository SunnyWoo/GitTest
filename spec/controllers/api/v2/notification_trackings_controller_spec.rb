require 'spec_helper'

describe Api::V2::NotificationTrackingsController, type: :controller do
  before { @request.env.merge! api_header(2) }
  let(:notification) { create(:notification) }

  context '#create' do
    before do
      @guest = User.new_guest
    end
    it 'return sucess' do
      attributes = { notification_id: notification.id,
                     device_token: @guest.auth_token }
      post :create, attributes
      expect(response).to be_success
      expect(response.code.to_i).to be(201)
      notification_tracking = response_json['notification_tracking']
      expect(notification_tracking['notification_id']).to eq(notification.id)
      expect(notification_tracking['device_token']).to eq(attributes[:device_token])
      expect(notification.tap(&:reload).notification_trackings_count).to eq(1)
    end

    it 'return 404, without notification_id' do
      attributes = { device_token: @guest.auth_token }
      post :create, attributes
      expect(response.code.to_i).to be(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end

    it 'return 404, error notification_id' do
      attributes = { notification_id: 9999,
                     device_token: @guest.auth_token }
      post :create, attributes
      expect(response.code.to_i).to be(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end
  end
end
