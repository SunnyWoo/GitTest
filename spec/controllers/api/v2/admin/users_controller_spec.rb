require 'spec_helper'

describe Api::V2::Admin::UsersController, type: :controller do
  before { @request.env.merge! api_header(2) }

  context 'POST :create' do
    Given(:user) { User.last }
    Given(:user_params) { attributes_for(:user, mobile: '1394123454', role: 'guest') }
    When { post :create, user: user_params }
    Then { user.email == user_params[:email] }
    And { user.name == user_params[:name] }
    And { user.mobile == user_params[:mobile] }
    And { user.role == user_params[:role] }
  end

  context 'GET :show' do
    Given(:serializer) { JSON.parse(Api::V2::Admin::UserSerializer.new(user).to_json) }
    Given(:user) { create(:user) }
    When { get :show, id: user.id }
    Then { response.status == 200 }
    And { response_json['user'] == serializer['user'] }
  end

  context 'PUT :update' do
    Given!(:user) { create(:user) }
    Given(:user_params) do
      {
        name: 'UpdateName'
      }
    end
    When { put :update, id: user.id, user: user_params }
    Then { response.status == 200 }
    And { response_json['user']['name'] == 'UpdateName' }
  end

  context 'DELETE :destroy' do
    Given!(:user) { create(:user) }
    When { delete :destroy, id: user.id }
    Then { response.status == 200 }
    And { User.count == 0 }
  end
end
