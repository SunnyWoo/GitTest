require 'spec_helper'

describe Api::V1::My::WorksController, type: :controller do
  before { @request.env.merge! api_header(1) }

  let(:product_model) { create(:product_model) }
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }

  context 'index' do
    it 'status 200' do
      work || die
      get :index, auth_token: user.auth_token
      expect(response_json.size).to eq(1)
    end
    it 'miss auth_token' do
      get :index, {}
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to eq('Missing params: auth_token')
    end
  end

  context 'show' do
    it 'status 200 by uuid' do
      get :show, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).not_to be nil
    end

    it 'status 404' do
      get :show, uuid: 999, auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['message']).to eq('Not found')
    end

    it 'updates artwork.user to current_user if current user is not guest but work owner is' do
      guest = User.new_guest
      user = create(:user)
      work = create(:work, user: guest)
      get :show, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).not_to be nil
      expect(work.reload.user).to eq(user)
    end
  end

  context 'create work' do
    it 'status 201' do
      post :create, name: 'work',
                    description: 'blah',
                    cover_image: fixture_file_upload('/test.jpg', 'image/jpeg'),
                    auth_token: user.auth_token,
                    model: product_model.name,
                    uuid: UUIDTools::UUID.timestamp_create.to_s
      expect(response).to be_success
      expect(response.status).to eq(201)
    end

    it 'creates work and artwork for user' do
      post :create, name: 'work',
                    description: 'blah',
                    cover_image: fixture_file_upload('/test.jpg', 'image/jpeg'),
                    auth_token: user.auth_token,
                    model: product_model.name,
                    uuid: UUIDTools::UUID.timestamp_create.to_s
      expect(user.works.first.name).to eq('work')
      expect(user.works.first.description).to eq('blah')
      expect(user.works.first.user).to eq(user)
    end

    it 'update with same uuid' do
      post :create, name: 'work1',
                    description: 'blah',
                    cover_image: fixture_file_upload('/test.jpg', 'image/jpeg'),
                    auth_token: user.auth_token,
                    model: product_model.name,
                    uuid: work.uuid
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(work.reload.name).to eq('work1')
    end

    it 'destroy all layers if update' do
      create(:layer, work: work)
      expect(work.reload.layers.count).to eq(1)
      post :create, name: 'work1',
                    description: 'blah',
                    cover_image: fixture_file_upload('/test.jpg', 'image/jpeg'),
                    auth_token: user.auth_token,
                    model: product_model.name,
                    uuid: work.uuid
      expect(work.reload.layers.count).to eq(0)
    end

    it 'updates artwork.user to current_user if current user is not guest but work owner is' do
      guest = User.new_guest
      user = create(:user)
      work = create(:work, user: guest)
      post :create, name: 'work',
                    description: 'blah',
                    cover_image: fixture_file_upload('/test.jpg', 'image/jpeg'),
                    auth_token: user.auth_token,
                    model: product_model.name,
                    uuid: work.uuid
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(work.reload.user).to eq(user)
    end
  end

  context 'create work check user agent' do
    it 'Unknown user agent' do
      @request.env.merge! 'HTTP_USER_AGENT' => 'konnamtb'
      post :create, name: 'work',
                    auth_token: user.auth_token,
                    model: product_model.name
      expect(response).to be_success
      expect(user.works.last.created_channel).to eq('api')
      expect(user.works.last.created_os_type).to eq('Unknown')
    end

    it 'ios app 1.0.0' do
      @request.env.merge! 'HTTP_USER_AGENT' => 'commandp_1.0_iOS_8.0_iPhone 5S'
      post :create, name: 'work',
                    auth_token: user.auth_token,
                    model: product_model.name
      expect(response).to be_success
      expect(user.works.last.created_channel).to eq('api')
      expect(user.works.last.created_os_type).to eq('iOS')
    end

    it 'Android app 1.0.0' do
      @request.env.merge! 'HTTP_USER_AGENT' => 'commandp_1.0_Android_SDK8_HTC Desire'
      post :create, name: 'work',
                    auth_token: user.auth_token,
                    model: product_model.name
      expect(response).to be_success
      expect(user.works.last.created_channel).to eq('api')
      expect(user.works.last.created_os_type).to eq('Android')
    end
  end

  context 'finish' do
    it 'status 200 by uuid' do
      patch :finish, uuid: work.uuid, auth_token: user.auth_token
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['uuid']).to eq work.uuid
      expect(response_json['finished']).to be true
      expect(response_json['uuid']).not_to be nil
    end

    it 'status 404' do
      patch :finish, uuid: '99999', auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to match('Not found')
    end

    it 'updates artwork.user to current_user if current user is not guest but work owner is' do
      guest = User.new_guest
      user = create(:user)
      work = create(:work, user: guest)
      patch :finish, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).to eq work.uuid
      expect(response_json['finished']).to be true
      expect(response_json['uuid']).not_to be nil
      expect(work.reload.user).to eq(user)
    end
  end

  context 'update' do
    it 'status 200' do
      put :update, uuid: work.uuid, name: 'update_work', auth_token: user.auth_token
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end

    it 'status 404' do
      put :update, uuid: 9999, name: 'update_work', auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to match('Not found')
    end

    context 'remove all layers' do
      Given(:layer) { create(:layer, work: work) }
      When { patch :update, uuid: work.uuid, name: 'update_work', auth_token: user.auth_token }
      Then { expect(work.reload.layers.count).to eq(0) }
    end

    it 'updates artwork.user to current_user if current user is not guest but work owner is' do
      guest = User.new_guest
      user = create(:user)
      work = create(:work, user: guest)
      put :update, uuid: work.uuid, name: 'update_work', auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
      expect(work.reload.user).to eq(user)
    end
  end

  context 'destroy' do
    it 'status 200 by uuid' do
      delete :destroy, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end

    it 'status 404' do
      delete :destroy, uuid: 999, auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['message']).to eq('Not found')
    end

    it 'destroys work if current user is not guest but work owner is' do
      guest = User.new_guest
      user = create(:user)
      work = create(:work, user: guest)
      delete :destroy, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
      expect(Work).not_to be_exist(uuid: work.uuid)
    end
  end
end
