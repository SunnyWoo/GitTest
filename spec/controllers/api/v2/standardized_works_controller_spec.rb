require 'spec_helper'

describe Api::V2::StandardizedWorksController, type: :controller, elasticsearch: true do
  render_views

  Given!(:designer) { create(:designer) }
  Given!(:work) { create(:standardized_work, :published, user: designer) }
  Given!(:series_work) { create(:standardized_work, :published, user: designer) }
  before do
    @request.env.merge! api_header(2)
    work.__elasticsearch__.index_document
    series_work.__elasticsearch__.index_document
  end
  context '#index' do
    context 'returns ok when everything is fine' do
      When { get :index, query: 'work', sort: 'new' }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'use recommend sort', signed_in: false do
      Given!(:recommend_sort) { create :recommend_sort, sort: 'price_desc' }
      When { get :index, access_token: access_token, sort: 'recommend', format: :json }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['meta']['request_query']['sort'] == recommend_sort.sort }
    end
  end
end
