require 'spec_helper'

describe Api::V3::My::AssetPackagesController, :api_v3, type: :controller do
  context 'when a user signs in', signed_in: :normal do
    Given(:package) { create :available_asset_package, countries: [:US] }
    before { user.asset_packages << package }
    context '#index' do
      context 'returns ok if everything is fine' do
        When { get :index, access_token: access_token }
        Then { response.status.to_i == 200 }
        And { expect(response).to render_template(:index) }
      end
    end

    context '#create' do
      context 'returns 200 if the package is suitable for creating condition' do
        Given!(:new_package) { create :available_asset_package, countries: [:US] }
        Given!(:count) { new_package.downloads_count }
        When { post :create, access_token: access_token, id: new_package.id }
        Then { response.status.to_i == 200 }
        And { user.asset_packages(true).count == 2 }
        And { new_package.reload.downloads_count == (count + 1) }
        And { expect(response).to render_template('api/v3/asset_packages/show') }
      end

      context 'does not create duplicated asset_past to user' do
        before { expect(user.asset_packages.count).to eq 1 }
        Given!(:count) { package.downloads_count }
        When { post :create, access_token: access_token, id: package.id }
        Then { response.status.to_i == 200 }
        And { user.asset_packages(true).count == 1 }
        And { package.reload.downloads_count == count }
      end
    end

    context '#destroy' do
      context 'returns 200 if the package is fit for destroying' do
        When { delete :destroy, access_token: access_token, id: package.id }
        Then { response.status.to_i == 200 }
        And { user.asset_packages(true).count == 0 }
        And { expect(response).to render_template('api/v3/asset_packages/show') }
      end

      context 'does not destroy the asset_packages that does not belong to current_user' do
        before { expect(user.asset_packages.count).to eq 1 }
        Given(:new_package) { create :available_asset_package, countries: [:US] }
        When { delete :destroy, access_token: access_token, id: new_package.id }
        Then { user.asset_packages(true).count == 1 }
      end
    end
  end

  context 'when a user does not signs in', signed_in: false do
    Given(:package) { create :available_asset_package, countries: [:US] }
    context '#index' do
      context 'returns 404' do
        When { get :index, access_token: access_token }
        Then { response.status.to_i == 403 }
      end
    end

    context '#create' do
      context 'returns 404' do
        When { post :create, access_token: access_token, id: package.id }
        Then { response.status.to_i == 403 }
      end
    end

    context '#destroy' do
      context 'returns 404' do
        When { delete :destroy, access_token: access_token, id: package.id }
        Then { response.status.to_i == 403 }
      end
    end
  end
end
