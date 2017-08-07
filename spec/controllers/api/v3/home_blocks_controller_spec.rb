require 'spec_helper'

describe Api::V3::HomeBlocksController, :api_v3, type: :controller do
  describe '/home_blocks', signed_in: false do
    it 'returns all home blocks' do
      create_list(:home_block, 3)
      get :index, access_token: access_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/home_blocks/index')
    end
  end
end
