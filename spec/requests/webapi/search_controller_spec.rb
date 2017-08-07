require 'spec_helper'

describe Webapi::SearchController, type: :request do
  let!(:work) { create(:work, :is_public) }

  context 'works' do
    it 'returns works with given name' do
      get webapi_search_works_path, { name: 'work' }
      expect(response.status).to eq(200)
      expect(response_json['works'].size).to be 1
    end

    it 'returns no works if given name was not match' do
      get webapi_search_works_path, { name: 'qoo' }
      expect(response.status).to eq(200)
      expect(response_json['works'].size).to be 0
    end

    it 'search with page and per_page' do
      get webapi_search_works_path, { name: 'work' , page: 1, per_page: 20 }
      expect(response.status).to eq(200)
      expect(response_json['works'].size).to be 1
      expect(response_json['meta']['per_page']).to eq 20
      expect(response_json['meta']['current_page']).to eq 1
    end
  end

end
