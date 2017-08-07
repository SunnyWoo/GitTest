require 'spec_helper'

describe LayersController, type: :controller do
  include Devise::TestHelpers

  let(:work) { create(:work) }
  let(:user) { User.new_guest }
  before { user.save }

  describe '#index' do
    it 'authenticates user' do
      get :index, work_id: work
      expect(response.status).to eq(302)
    end

    it 'returns layers data' do
      sign_in :user, user
      file = fixture_file_upload('test.jpg', 'image/jpeg')
      post :create, locale: 'zh-TW', work_id: work, file: file, uuid: SecureRandom.uuid,
                    position: '1', scale_x: '0.5', scale_y: '0.5', format: :json
      get :index, locale: 'zh-TW', work_id: work, format: :json
      expect(response.status).to eq(200)
      expect(response).to render_template('layers/index')
    end

    it "can't find work" do
      sign_in :user, user
      get :index, locale: 'zh-TW', work_id: '9999'
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    context 'user signed in', sigend_in: true do
      it 'authenticates user' do
        file = fixture_file_upload('test.jpg', 'image/jpeg')
        post :create, work_id: work, file: file
        expect(response.status).to eq(302)
      end

      it 'creates photo layer' do
        sign_in :user, user
        file = fixture_file_upload('test.jpg', 'image/jpeg')
        post :create, locale: 'zh-TW', work_id: work, file: file, uuid: SecureRandom.uuid,
                      position: '1', scale_x: '0.5', scale_y: '0.5'
        expect(response.status).to eq(201)
        layer = work.layers.first
        expect(layer.layer_type).to eq('photo')
        expect(response.body).to eq({ url: layer.filtered_image.url, uuid: layer.uuid }.to_json)
      end

      it 'creates other layer' do
        sign_in :user, user
        params = {
          layer_type: 'shape',
          position_x: '10',
          position_y: '20',
          orientation: '30',
          scale_x: '0.4',
          scale_y: '0.5',
          font_name: 'six',
          font_text: 'seven',
          text_alignment: '1',
          transparent: '0.8',
          position: 9,
          uuid: SecureRandom.uuid,
          material_name: 'cp_shapes_01'
        }
        post :create, params.merge(locale: 'zh-TW', work_id: work, format: :json)
        expect(response.status).to eq(201)
        expect(assigns(:layer).layer_type).to eq(params[:layer_type])
        expect(assigns(:layer).position_x).to eq(params[:position_x].to_f)
        expect(assigns(:layer).position_y).to eq(params[:position_y].to_f)
        expect(assigns(:layer).orientation).to eq(params[:orientation].to_f)
        expect(assigns(:layer).scale_x).to eq(params[:scale_x].to_f)
        expect(assigns(:layer).scale_y).to eq(params[:scale_y].to_f)
        expect(assigns(:layer).font_name).to eq(params[:font_name])
        expect(assigns(:layer).font_text).to eq(params[:font_text])
        expect(assigns(:layer).text_alignment).to eq('Center')
        expect(assigns(:layer).transparent).to eq(params[:transparent].to_f)
        expect(assigns(:layer).uuid).to eq(params[:uuid])
        expect(assigns(:layer).material_name).to eq(params[:material_name])
        expect(response).to render_template('layers/show')
      end

      it 'returns error if params is not valid' do
        sign_in :user, user
        params = { layer_type: 'shape' }
        post :create, params.merge(locale: 'zh-TW', work_id: work)
        expect(response.status).to eq(422)
        layer = work.layers.first
        expect(layer).to be_nil
      end
    end
  end

  describe '#update' do
    it 'authenticates user' do
      file = fixture_file_upload('test.jpg', 'image/jpeg')
      patch :update, work_id: work, file: file, id: '123'
      expect(response.status).to eq(302)
    end

    it 'updates layer' do
      sign_in :user, user
      params = {
        layer_type: 'shape',
        position_x: '10',
        position_y: '20',
        orientation: '30',
        scale_x: '0.4',
        scale_y: '0.5',
        font_name: 'six',
        font_text: 'seven',
        text_alignment: '1',
        transparent: '0.8',
        position: 9,
        uuid: id = SecureRandom.uuid,
        material_name: 'cp_shapes_01'
      }
      post :create, params.merge(locale: 'zh-TW', work_id: work, format: :json)
      patch :update, work_id: work, locale: 'zh-TW', id: id, position_x: '-10', format: :json

      expect(assigns(:layer).position_x).to eq(-10)
      expect(response).to render_template('layers/show')
    end

    it 'returns error if params is not valid' do
      sign_in :user, user
      params = {
        layer_type: 'shape',
        position_x: '10',
        position_y: '20',
        orientation: '30',
        scale_x: '0.4',
        scale_y: '0.5',
        font_name: 'six',
        font_text: 'seven',
        text_alignment: '1',
        transparent: '0.8',
        position: 9,
        uuid: id = SecureRandom.uuid,
        material_name: 'cp_shapes_01'
      }
      post :create, params.merge(locale: 'zh-TW', work_id: work, format: :json)
      patch :update, work_id: work, locale: 'zh-TW', id: id, material_name: 'whatever'
      expect(response.status).to eq(422)
    end
  end

  describe '#destroy' do
    it 'authenticates user' do
      file = fixture_file_upload('test.jpg', 'image/jpeg')
      delete :destroy, work_id: work, file: file, id: '123'
      expect(response.status).to eq(302)
    end

    context 'destroy' do
      before do
        sign_in :user, user
        params = {
          layer_type: 'shape',
          position_x: '10',
          position_y: '20',
          orientation: '30',
          scale_x: '0.4',
          scale_y: '0.5',
          font_name: 'six',
          font_text: 'seven',
          text_alignment: '1',
          transparent: '0.8',
          position: 9,
          uuid: @id = SecureRandom.uuid,
          material_name: 'cp_shapes_01'
        }
        post :create, params.merge(locale: 'zh-TW', work_id: work, format: :json)
      end

      it 'destroy layer' do
        delete :destroy, locale: 'zh-TW', work_id: work, id: @id
        layer = work.layers.first
        expect(layer).to be_nil
        expect(response.body).to eq({ status: 'ok' }.to_json)
      end

      it 'destroy layer 2 times' do
        delete :destroy, locale: 'zh-TW', work_id: work, id: @id, format: :json
        layer = work.layers.first
        expect(layer).to be_nil
        expect(response.body).to eq({ status: 'ok' }.to_json)

        delete :destroy, locale: 'zh-TW', work_id: work, id: @id, format: :json
        expect(response.status).to eq(404)
        expect(response.body).to eq(RecordNotFoundError.new.to_json)
      end
    end
  end
end
