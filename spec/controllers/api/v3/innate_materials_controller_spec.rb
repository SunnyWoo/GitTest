require 'spec_helper'

describe Api::V3::InnateMaterialsController, :api_v3, type: :controller do
  describe '#index', signed_in: false do
    When { get :index, access_token: access_token }
    Then { response.status == 200 }
    And { expect(response_json['stickers'][0]['url']).not_to be_nil }
    And { expect(response_json['stickers'][0]['name']).not_to be_nil }
    And { expect(response_json['shapes'][0]['url']).not_to be_nil }
    And { expect(response_json['shapes'][0]['name']).not_to be_nil }
    And { expect(response_json['typographies'][0]['url']).not_to be_nil }
    And { expect(response_json['typographies'][0]['name']).not_to be_nil }
  end
end
