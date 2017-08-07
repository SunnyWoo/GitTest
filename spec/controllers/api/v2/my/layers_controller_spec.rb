require 'spec_helper'

describe Api::V2::My::LayersController, type: :controller do
  before { request.env.merge! api_header(2) }
  let(:product_model) { create(:product_model) }
  let(:work_spec) { product_model.specs.first }
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }

  describe '#update' do
    it 'returns 404 if the work uuid is not used' do
      work_uuid = SecureRandom.uuid
      uuid = SecureRandom.uuid
      put :update, work_uuid: work_uuid, uuid: uuid, auth_token: user.auth_token
      expect(response.status).to eq(404)
    end

    it 'creates layer if the uuid is not used' do
      uuid = SecureRandom.uuid
      put :update, work_uuid: work.uuid, uuid: uuid, auth_token: user.auth_token,
                   layer_type: 'photo',
                   position: -1
      layer = Layer.last
      expect(response).to render_template('api/v3/my/layers/show')
      expect(layer.layer_type).to eq('photo')
      expect(layer.position).to eq(-1)
    end

    it 'updates work if the uuid is used and the layer is masked' do
      layer = work.layers.create(layer_type: 'photo', position: -1, mask_id: 1)
      put :update, work_uuid: work.uuid, uuid: layer.uuid, auth_token: user.auth_token,
                   layer_type: 'photo', position: 1
      layer = Layer.last
      expect(response).to render_template('api/v3/my/layers/show')
      expect(layer.layer_type).to eq('photo')
      expect(layer.position).to eq(1)
    end

    it 'updates work if the uuid is used and the layer is not masked' do
      layer = work.layers.create(layer_type: 'photo', position: -1)
      put :update, work_uuid: work.uuid, uuid: layer.uuid, auth_token: user.auth_token,
                   layer_type: 'photo', position: 1, mask_id: 1
      layer = Layer.last
      expect(response).to render_template('api/v3/my/layers/show')
      expect(layer.layer_type).to eq('photo')
      expect(layer.position).to eq(1)
      expect(layer.mask_id).to eq(1)
    end

    it 'returns 422 if some params are invalid' do
      uuid = SecureRandom.uuid
      put :update, work_uuid: work.uuid, uuid: uuid, auth_token: user.auth_token,
                   layer_type: 'shape',
                   position: -1
      expect(response.status).to eq(422)
      expect(Layer.last).to be_nil
    end
  end

  describe '#destroy' do
    it 'deletes the layer' do
      layer = work.layers.create(layer_type: 'photo', position: -1)
      delete :destroy, work_uuid: work.uuid, uuid: layer.uuid, auth_token: user.auth_token
      expect(Layer.exists?(uuid: layer.uuid)).to be(false)
    end
  end
end
