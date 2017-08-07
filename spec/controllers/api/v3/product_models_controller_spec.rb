require 'spec_helper'

describe Api::V3::ProductModelsController, :api_v3, type: :controller do
  describe '#index', signed_in: false do
    Given!(:model) { create :product_model }
    context 'returns all available product_models info' do
      When { get :index, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end
  end

  describe '#show', signed_in: false do
    context 'returns correct product_models info' do
      Given(:product_model) { create :product_model }
      When { get :show, access_token: access_token, id: product_model.id }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end

    context 'returns correct product_models info with params id which is the model key' do
      Given(:product_model) { create :product_model }
      When { get :show, access_token: access_token, id: product_model.key }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end
  end

  describe '#des_images', signed_in: false do
    context 'returns correct des_images info' do
      Given(:product_model) { create :product_model, :with_des_images }
      When { get :des_images, access_token: access_token, id: product_model.id }
      Then { response.status == 200 }
      And { expect(response).to render_template(:des_images) }
    end
  end
end
