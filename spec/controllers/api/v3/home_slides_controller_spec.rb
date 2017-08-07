require 'spec_helper'

describe Api::V3::HomeSlidesController, :api_v3, type: :controller do
  describe '/home_slides', signed_in: false do
    it 'returns all home slides' do
      create_list(:home_slide, 3, set: 'default')
      get :index, access_token: token.token, set: 'default'
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/home_slides/index')
    end

    it 'does not returns slides that set not matched' do
      create_list(:home_slide, 3, set: 'create')
      get :index, access_token: token.token, set: 'default'
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/home_slides/index')
    end
  end
end
