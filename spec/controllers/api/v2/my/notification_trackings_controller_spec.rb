require 'spec_helper'

describe Api::V2::My::NotificationTrackingsController, type: :controller do
  before { @request.env.merge! api_header(2) }
  let(:user) { create(:user) }
  let(:notification) { create(:notification) }

  context '#create' do
    let!(:guest) { User.new_guest }
    it 'return sucess' do
      attributes = { auth_token: user.auth_token,
                     notification_id: notification.id,
                     device_token: guest.auth_token }
      post :create, attributes
      expect(response).to be_success
      expect(response.code.to_i).to be(201)
      notification_tracking = response_json['notification_tracking']
      expect(notification_tracking['notification_id']).to eq(notification.id)
      expect(notification_tracking['device_token']).to eq(attributes[:device_token])
    end

    it 'return error, without notification_id' do
      attributes = { auth_token: user.auth_token,
                     device_token: guest.auth_token }
      post :create, attributes
      expect(response.code.to_i).to be(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end
  end
end
