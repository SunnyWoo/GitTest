require 'spec_helper'

describe 'Auth', type: :request do
  let(:test_user) { create :user }

  context 'Normal login' do
    it 'with correct facebook info', :vcr do
      stub_request(:get, 'https://graph.facebook.com/1428842454109275/picture?height=999&width=999')
      post api_sign_in_path, { provider: 'facebook',
                               uid: test_user.id,
                               access_token: test_user.auth_token,
                               email: test_user.email }, api_header(1)
      expect(response.status).to eq(200)
      expect(response_json['auth_token']).not_to be_nil
      user = User.find(response_json['user_id'])
      expect(user.avatar).not_to be_nil
      expect(user.name).not_to be_nil
      expect(user.email).not_to be_nil
      expect(user.gender).not_to be_nil
    end
  end

  let(:owner) { create(:user) }

  it 'migrate guest user to user', :vcr do
    guest = User.new_guest
    work = create(:work, user: guest)
    order = create(:order, user: guest)
    device = create(:device, user: guest)
    stub_request(:get, 'https://graph.facebook.com/115589612113904/picture?height=999&width=999')

    post api_sign_in_path, { provider: 'facebook',
                             uid: test_user.id,
                             access_token: test_user.auth_token,
                             email: test_user.email,
                             old_auth_token: guest.auth_token }, api_header(1)

    expect(response.status).to eq(200)
    expect(guest.reload.role).to eq('die')
    expect(response_json['user_id']).not_to be nil

    expect(work.reload.user_id).to eq(response_json['user_id'])
    expect(order.reload.user_id).to eq(response_json['user_id'])
    expect(device.reload.user_id).to eq(response_json['user_id'])
  end

  context 'sign_out' do
    it 'status 200' do
      auth_token = owner.auth_token
      delete api_sign_out_path, { auth_token: auth_token }, api_header(1)
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
      expect(AuthToken.find_by(token: auth_token)).to be_nil
    end
  end
end
