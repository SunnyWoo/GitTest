require 'spec_helper'

describe Api::V1::ProductModelsController, type: :controller do
  before { @request.env.merge! api_header(1) }
  let!(:product_model) { create(:product_model) }

  context 'index' do
    it 'status 200' do
      get :index
      expect(response).to be_success
      expect(response_json[0]['currencies'].size).not_to eq(0)
    end
  end
end
