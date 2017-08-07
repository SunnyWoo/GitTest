require 'spec_helper'

describe Api::V3::FontsController, :api_v3, type: :controller do
  describe '#index', signed_in: :false do
    When { get :index, access_token: access_token }
    Then { response.status == 200 }
    And { expect(response_json['fonts'][0]['name']).not_to be_nil }
    And { expect(response_json['fonts'][0]['url']).not_to be_nil }
  end
end
