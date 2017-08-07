require 'spec_helper'

describe Api::V3::CartItemsController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  before { expect(controller).to receive(:check_user).and_call_original }

  Given!(:work) { create(:work) }
  Given!(:standardized_work) { create(:standardized_work) }
  Given!(:quantity) { rand(10) + 1 }
  Given(:cart) { CartSession.new(controller: controller, user_id: user.id) }

  describe 'POST /cart/items' do
    context 'add an item', signed_in: :normal do
      When { post :create, access_token: access_token, work_id: work.id, quantity: quantity }
      Then { response.status == 200 }
      And { response_json['meta']['items_count'] == 1 }
    end

    context 'add an standardized_work item', signed_in: :normal do
      When { post :create, access_token: access_token, work_id: standardized_work.id, quantity: quantity }
      Then { response.status == 200 }
      And { response_json['meta']['items_count'] == 1 }
    end

    context 'add an item' do
      before do
        work2 = create(:work)
        cart.add_items(work2.uuid, quantity)
        cart.save
      end

      context 'add an item by uuid', signed_in: :normal do
        When { post :create, access_token: access_token, work_uuid: work.uuid, quantity: quantity }
        Then { response.status == 200 }
        And { response_json['meta']['items_count'] == 2 }
      end

      context 'add an item by gid', signed_in: :normal do
        When { post :create, access_token: access_token, gid: work.to_gid_param, quantity: quantity }
        Then { response.status == 200 }
        And { response_json['meta']['items_count'] == 2 }
      end

      context 'when git not exist', signed_in: :normal do
        When { post :create, access_token: access_token, gid: 'bad_work_gid', quantity: quantity }
        Then { response.status == 404 }
      end

      context 'add an item by slug', signed_in: :normal do
        When { post :create, access_token: access_token, work_uuid: work.slug, quantity: quantity }
        Then { response.status == 200 }
        And { response_json['meta']['items_count'] == 2 }
      end
    end

    context 'when item not found', signed_in: :normal do
      When { post :create, access_token: access_token, work_id: 'bad_work_id', quantity: quantity }
      Then { response.status == 404 }
    end

    context 'when quantity < 0', signed_in: :normal do
      When { post :create, access_token: access_token, work_id: work.id, quantity: -1 }
      Then { response.status == 400 }
      And { response_json['error'] == 'Invalid parameter quantity' }
    end
  end

  describe 'PUT /cart/items' do
    before do
      cart.add_items(work.to_gid, 1)
      cart.save
    end

    context 'update an item', signed_in: :normal do
      When { put :update, access_token: access_token, work_uuid: work.uuid, quantity: quantity }
      Then { response.status == 200 }
      And { response_json['cart'][work.to_gid.to_s] == quantity }
      And { response_json['meta']['items_count'] == 1 }
    end

    context 'update a standardized_work item', signed_in: :normal do
      before do
        cart.add_items(standardized_work.to_gid, 1)
        cart.save
      end
      When { put :update, access_token: access_token, work_uuid: standardized_work.uuid, quantity: quantity }
      Then { response.status == 200 }
      And { response_json['cart'][standardized_work.to_gid.to_s] == quantity }
      And { response_json['meta']['items_count'] == 2 }
    end

    context 'when item not found', signed_in: :normal do
      When { put :update, access_token: access_token, work_uuid: 'bad_work_id', quantity: quantity }
      Then { response.status == 404 }
    end

    context 'when quantity < 0', signed_in: :normal do
      When { put :update, access_token: access_token, work_uuid: work.uuid, quantity: -1 }
      Then { response.status == 400 }
      And { response_json['error'] == 'Invalid parameter quantity' }
    end
  end

  describe 'DELETE /cart/delete_item' do
    context 'delete item', signed_in: :normal do
      Given(:item) { response_json['cart']['order_items'][0] }

      before do
        cart.add_items(work.to_gid, quantity)
        cart.save
      end

      When { delete :destroy, access_token: access_token, work_id: work.id }
      Then { response.status == 200 }
      And { response_json['meta']['items_count'] == 0 }
    end
  end
end
