require 'spec_helper'

RSpec.describe Api::V2::MobileUisController, type: :controller do
  before { @request.env.merge!(api_header(2)) }
  let!(:ios_ui) { create(:mobile_ui, is_enabled: true) }

  context '#template' do
    it 'return ok when params provided correctly' do
      get :template, key: 'shop'
      expect(response).to be_ok
      expect(response).to render_template('api/v3/mobile_uis/show')
      expect(assigns(:mobile_ui)).to be_present
    end

    it 'return 404 when params provided correctly' do
      get :template, key: 'shopppppp'
      expect(response.code.to_i).to eq 400
    end

    it 'return default ui when there is no hotest_enabled ui' do
      ios_ui.update is_enabled: false
      default_ui = create(:mobile_ui, default: true, title: 'Zidane')
      get :template, key: 'shop'
      expect(response).to be_ok
      expect(response).to render_template('api/v3/mobile_uis/show')
      expect(assigns(:mobile_ui)).to eq(default_ui)
    end
  end
end
