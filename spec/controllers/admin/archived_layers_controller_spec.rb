require 'rails_helper'

RSpec.describe Admin::ArchivedLayersController, type: :controller do
  before do
    setup_admin
    sign_in :admin, create(:admin)
  end

  describe 'GET index' do
    it 'returns layers' do
      work = create(:work, layers: [build(:layer)]).create_archive
      get :index, archived_work_id: work.id, locale: 'zh-TW', format: :json
      expect(assigns(:layers)).to eq(work.layers)
      expect(response).to render_template('api/v3/archived_layers/index')
    end
  end

  describe 'PATCH update' do
    it 'updates and returns layer' do
      layer = create(:archived_layer)
      patch :update, locale: 'zh-TW', format: :json, id: layer.id, layer: { position_x: layer.position_x + 1 }
      expect(assigns(:layer)).to eq(layer)
      expect(assigns(:layer).position_x).to eq(layer.position_x + 1)
      expect(response).to render_template('api/v3/archived_layers/show')
    end
  end
end
