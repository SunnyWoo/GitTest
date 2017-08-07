require 'spec_helper'

describe Api::V3::My::WorksController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  before { expect(controller).to receive(:check_user).and_call_original }

  Given(:product_model) { create(:product_model) }
  Given(:user) { create(:user) }
  Given(:work) { create(:work, user: user) }

  describe '#index' do
    context 'when user signed in', signed_in: :normal do
      context 'return 200' do
        When { get :index, access_token: access_token }
        Then { expect(response).to render_template(:index) }
      end
    end
  end

  describe '#show' do
    context 'user signed in', signed_in: :normal do
      context 'returns the work if owned by current user'do
        When { work || go(die) }
        When { get :show, uuid: work.uuid, access_token: access_token }
        Then { expect(response).to render_template(:show) }
      end

      context 'returns 404 if the work is not owned by current user' do
        When { work.update(user: create(:user)) }
        When { get :show, uuid: work.uuid, access_token: access_token }
        Then { expect(response.status).to eq(404) }
      end

      context 'returns 404 if the uuid is not used' do
        When { get :show, uuid: 'what-the-fuck-y-u-give-a-wrong-uuid', access_token: access_token }
        Then { expect(response.status).to eq(404) }
      end
    end
  end

  describe '#update' do
    context 'user sigend in', signed_in: :normal do
      Given(:cover_image_aid) { create(:attachment).aid }

      context 'creates work if the uuid is not used' do
        Given(:uuid) { SecureRandom.uuid }
        When do
          put :update, uuid: uuid, access_token: access_token,
                       name: 'hello', model_id: product_model.id,
                       cover_image_aid: cover_image_aid
        end
        Given(:work) { Work.last }
        Then { expect(response).to render_template(:show) }
        And { expect(work.name).to eq('hello') }
        And { expect(work.product).to eq(product_model) }
        And { expect(work.user).to eq(user) }
        And { work.application == controller.current_application }
        And { work.attached_cover_image_id.nil? }
        And { work.cover_image.present? }
      end

      context 'when feature flag on, creates layer with cover_image_aid' do
        Given(:feature_flag_on) { double(FeatureFlag::Feature, enable_for_current_session?: true) }
        Given(:uuid) { SecureRandom.uuid }
        When { expect(controller).to receive(:feature).with(:api_v3_my_work_enable_attachment_aid).and_return(feature_flag_on).twice }
        When do
          put :update, uuid: uuid, access_token: access_token,
                       name: 'hello cover_image_aid',
                       model_id: product_model.id,
                       cover_image_aid: cover_image_aid
        end
        Given(:work) { Work.last }
        Then { expect(response).to render_template(:show) }
        And { expect(work.name).to eq('hello cover_image_aid') }
        And { expect(work.product).to eq(product_model) }
        And { expect(work.user).to eq(user) }
        And { work.application == controller.current_application }
        And { work.attached_cover_image_id.present? }
        And { work.cover_image.present? }
      end

      context 'updates work if the uuid is used' do
        When do
          put :update, uuid: work.uuid, access_token: access_token,
                       name: 'hello', model_id: product_model.id
        end
        When { work.reload }
        Then { expect(response).to render_template('api/v3/works/show') }
        And { expect(work.name).to eq('hello') }
        And { expect(work.product).to eq(product_model) }
        And { expect(work.user).to eq(user) }
      end

      context 'returns 422 if some params are invalid' do
        Given(:uuid) { SecureRandom.uuid }
        When do
          put :update, uuid: uuid, access_token: access_token,
                       name: '', model_id: product_model.id
        end
        Then { expect(response.status).to eq(422) }
        Then { expect(Work.last).to be_nil }
      end

      context 'updates user if work user is guest but current user is not' do
        Given(:guest_user) { User.new_guest }
        When { work.update!(user: guest_user) }
        When do
          put :update, uuid: work.uuid, access_token: access_token,
                       name: 'hello', model_id: product_model.id
        end
        Then { expect(Work.last.user).to eq(user) }
      end

      # NOTE 在 find_or_initialize_work 時會因為找不到所以使用該 uuid 建立新 work -> 然後爆炸
      context 'returns 422 if work user and current user are not guest' do
        Given(:scope) { 'public' }
        Given(:other_user) { create(:user) }
        Given(:token2) { create(:access_token, resource_owner_id: other_user.id, scopes: scope) }
        Given(:access_token2) { token2.token }
        When { work.user = other_user }
        When do
          put :update, uuid: work.uuid, access_token: access_token2,
                       name: 'hello', model_id: product_model.id
        end
        Then { expect(Work.last.user).not_to eq(other_user) }
        And { expect(response.status).to eq(422) }
      end
    end
  end

  describe '#finish' do
    context 'user signed in', signed_in: :normal do
      context 'finishes and returns the work' do
        When { post :finish, uuid: work.uuid, access_token: access_token }
        When { work.reload }
        Then { expect(response).to render_template('api/v3/works/show') }
        And { expect(Work.last).to be_finished }
      end

      context 'returns 404 if the uuid is not used' do
        When { post :finish, uuid: 'what-the-fuck-y-u-give-a-wrong-uuid', access_token: access_token }
        Then { expect(response.status).to eq(404) }
      end

      context 'returns 200 with simple true' do
        When { post :finish, uuid: work.uuid, access_token: access_token, simple: true }
        Then { expect(response.status).to eq(200) }
      end
    end
  end

  describe '#destroy', signed_in: :normal do
    Given!(:work) { create :work, user: user }
    Given!(:count) { Work.count }
    Then do
      expect { delete :destroy, access_token: access_token, uuid: work.uuid }.to change { Work.count }.by(-1)
    end
    And { expect(response).to render_template('api/v3/works/show') }
    And { Work.with_deleted.include? work }
  end
end
