require 'spec_helper'

describe Store::CartsController, type: :controller do
  Given(:store) { create :store }
  context '#add' do
    Given(:work) { create :work }
    Given(:standardized_work) { create :standardized_work }
    Given(:user) { create :user }
    context 'returns 200 with item work' do
      When { post :add, store_id: store.id, id: work.uuid, locale: :en }
      Then { response.status == 200 }
      And { response_json['meta']['items_count'] == 1 }
      And { response_json['cart'][work.to_gid.to_s].to_i == 1 }
    end

    context 'returns correct quantity with params quantity provided' do
      When { post :add, store_id: store.id, id: work.uuid, quantity: 3, locale: :en }
      Then { response_json['meta']['items_count'] == 1 }
      And { response_json['cart'][work.to_gid.to_s].to_i == 3 }
    end

    context 'returns 200 with item standardized_work' do
      When { post :add, store_id: store.id, id: standardized_work.uuid, locale: :en }
      Then { response_json['meta']['items_count'] == 1 }
      And { response_json['cart'][standardized_work.to_gid.to_s].to_i == 1 }
    end
  end

  context '#show' do
    When { get :show, store_id: store.id }
    Then { response.status == 302 }
  end
end
