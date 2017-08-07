require 'rails_helper'

RSpec.describe Api::V3::StoresController, :api_v3, type: :controller do
  describe '#show' do
    context 'with id' do
      Given(:store) { create(:store) }
      When { get :show, id: store.id }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/stores/show') }
    end

    context 'with slug' do
      Given(:store) { create(:store) }
      When { get :show, id: store.slug }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/stores/show') }
    end

    context 'when store not found' do
      Given(:store) { create(:store) }
      When { get :show, id: 'UNKNOWN' }
      Then { response.status == 404 }
    end
  end
end
