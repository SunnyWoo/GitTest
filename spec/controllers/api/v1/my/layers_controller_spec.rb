require 'spec_helper'
include ActionDispatch::TestProcess

describe Api::V1::My::LayersController, type: :controller do
  before { @request.env.merge! api_header(1) }

  let(:user) { create(:user) }
  let!(:work) { create(:work, user: user) }
  let!(:layer) { create(:layer, work: work) }

  context 'show' do
    it 'status 200 by uuid' do
      get :show, work_uuid: work.uuid, uuid: layer.uuid,
                 auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v1/layers/show')
    end

    it '404' do
      get :show, work_uuid: 321, uuid: 321, auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['message']).to match('Not found')
    end
  end

  context 'create' do
    it 'status 201' do
      post :create, work_uuid: work.uuid,
                    uuid: UUIDTools::UUID.timestamp_create.to_s,
                    auth_token: user.auth_token,
                    position: 1,
                    position_x: Random.rand(0.0..1000.0),
                    position_y: Random.rand(0.0..1000.0),
                    orientation: Random.rand(0.0..360.0),
                    scale_x: Random.rand(0.0..10.0),
                    scale_y: Random.rand(0.0..10.0),
                    color: 'black',
                    font_name: 'font_name',
                    font_text: 'font_text',
                    image: fixture_file_upload('test.jpg', 'image/jpeg'),
                    name: 'layer name',
                    layer_type: :photo,
                    filtered_image: fixture_file_upload('test.jpg', 'image/jpeg'),
                    filter_type: Random.rand(0..100),
                    layer_no: 'no1',
                    text_spacing_x: Random.rand(0..10),
                    text_spacing_y: Random.rand(0..10),
                    text_alignment: Random.rand(0..10),
                    transparent: Random.rand(0.0..10.0)
      expect(response.status).to eq(201)
      expect(response).to render_template('api/v1/layers/show')
    end

    it 'check layer position' do
      tmp_work = create(:work, user: user)
      post :create,           work_uuid: tmp_work.uuid,
                              uuid: UUIDTools::UUID.timestamp_create.to_s,
                              auth_token: user.auth_token,
                              position: 7,
                              material_name: 'layer name 5',
                              layer_type: :photo
      layer = tmp_work.layers.last
      expect(layer.position).to eq(7)
    end
  end

  context 'update' do
    it 'status 200 by uuid' do
      put :update, work_uuid: work.uuid, uuid: layer.uuid, auth_token: user.auth_token, name: 'update layer name'
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end
  end

  context 'destroy' do
    it 'status 200 by uuid' do
      delete :destroy, work_uuid: work.uuid, uuid: layer.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end
  end
end
