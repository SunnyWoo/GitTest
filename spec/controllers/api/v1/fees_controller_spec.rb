require 'spec_helper'

describe Api::V1::FeesController, type: :controller do
  context 'index' do
    it 'status 200' do
      get :index, {}
      expect(response).to be_success
    end
  end

  context 'shipping_fee' do
    it 'status 200' do
      create(:fee, name: '運費')
      get :shipping_fee, {}
      expect(response).to be_success
    end
  end
end
