require 'spec_helper'

describe Api::V3::ProvincesController, :api_v3, type: :controller do
  describe '/provinces', signed_in: false do
    it 'returns all home slides' do
      get :index, access_token: token.token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/provinces/index')
    end
  end
end
