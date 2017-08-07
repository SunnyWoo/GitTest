require 'spec_helper'

RSpec.describe Api::V3::My::AddressInfosController, :api_v3, type: :controller do
  describe 'GET /api/my/address_infos' do
    context 'when user sign in', signed_in: :normal do
      it 'returns user address_infos list' do
        address = create :address_info
        user.address_infos << address
        get :index, access_token: access_token
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/address_infos/index')
        expect(assigns(:address_infos)).to eq(user.address_infos)
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403' do
        get :index, access_token: access_token
        expect(response.status).to eq 403
      end
    end
  end

  describe 'POST /api/my/address_infos' do
    context 'when user signed in', signed_in: :normal do
      it 'returns ok with the address_info created correctly' do
        data = {
          name:         user.name,
          address_name: 'Jedi Planet',
          address:      'over there',
          phone:        '88527788',
          city:         'Yoda',
          email:        user.email,
          country_code: 'TW'
        }
        count = AddressInfo.count
        post :create, { access_token: access_token }.merge(data)
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/address_infos/show')
        expect(assigns(:address_info)).to eq(AddressInfo.last)
        expect(AddressInfo.count).to eq(count + 1)
      end

      it 'returns 422 without some necessary params' do
        data = {
          name:         user.name,
          address_name: 'Jedi Planet',
          city:         'Yoda',
          email:        user.email
        }
        count = AddressInfo.count
        post :create, { access_token: access_token }.merge(data)
        expect(response.status).to eq 422
        expect(AddressInfo.count).to eq count
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403' do
        data = {}
        post :create, { access_token: access_token }.merge(data)
        expect(response.status).to eq 403
      end
    end
  end

  describe 'PUT /api/my/address_infos/:id' do
    context 'when user signed in', signed_in: :normal do
      let!(:address_info) { create :address_info, billable: user }
      it 'returns ok with all correctly params' do
        data = { name: 'Luke', address_name: 'Luke Skywallker', address: 'Somewhere in Death Planet' }
        put :update, { access_token: access_token, id: address_info.id }.merge(data)
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/address_infos/show')
        expect(address_info.reload.name).to eq data[:name]
        expect(address_info.reload.address_name).to eq data[:address_name]
        expect(address_info.reload.address).to eq data[:address]
      end

      it 'returns 422 with invalid params' do
        data = { email: 'wtf1sdfsdff' }
        put :update, { access_token: access_token, id: address_info.id }.merge(data)
        expect(response.status).to eq 422
      end

      it 'returns 404 with nonexistent address_info id' do
        data = { name: 'Luke', address_name: 'Luke Skywallker', address: 'Somewhere in Death Planet' }
        put :update, { access_token: access_token, id: 'r2d2' }.merge(data)
        expect(response.status).to eq 404
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403' do
        data = { name: 'Luke', address_name: 'Luke Skywallker', address: 'Somewhere in Death Planet' }
        put :update, { access_token: access_token, id: 'r2d2' }.merge(data)
        expect(response.status).to eq 403
      end
    end
  end

  describe 'GET /api/my/address_infos/:id' do
    context 'when user signed in', signed_in: :normal do
      let!(:address_info) { create :address_info, billable: user }
      it 'returns ok when address_info exists' do
        get :show, access_token: access_token, id: address_info.id
        expect(response).to render_template('api/v3/address_infos/show')
        expect(response.status).to eq 200
      end

      it 'returns 404 when address_info does not exits' do
        get :show, access_token: access_token, id: 'r5d4'
        expect(response.status).to eq 404
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403 in' do
        get :show, access_token: access_token, id: 'r5d4'
        expect(response.status).to eq 403
      end
    end
  end

  describe 'DELETE /api/my/address_infos/:id' do
    context 'when user signed in', signed_in: :normal do
      let!(:address_info) { create :address_info, billable: user }
      it 'returns ok when user signed in' do
        delete :destroy, access_token: access_token, id: address_info.id
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/address_infos/show')
        expect(user.address_infos.reload.pluck(:id)).not_to include address_info.id
      end

      it 'returns 404 with the address_info id which did not belong to the user' do
        others_address_info = create :address_info
        delete :destroy, access_token: access_token, id: others_address_info.id
        expect(response.status).to eq 404
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403 when user did not sign in' do
        delete :destroy, access_token: access_token, id: 'r5d4'
        expect(response.status).to eq 403
      end
    end
  end
end
