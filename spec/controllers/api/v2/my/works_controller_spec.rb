require 'spec_helper'

describe Api::V2::My::WorksController, type: :controller do
  before { @request.env.merge! api_header(2) }
  let(:product_model) { create(:product_model) }
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }

  describe '#show' do
    it 'returns the work if owned by current user' do
      work || go(die)
      get :show, uuid: work.uuid, auth_token: user.auth_token
      expect(response).to render_template(:show)
    end

    it 'returns 404 if the work is not owned by current user' do
      work.update(user: create(:user))
      get :show, uuid: work.uuid, auth_token: user.auth_token
      expect(response.status).to eq(404)
    end

    it 'returns 404 if the uuid is not used' do
      get :show, uuid: 'what-the-fuck-y-u-give-a-wrong-uuid', auth_token: user.auth_token
      expect(response.status).to eq(404)
    end
  end

  describe '#update' do
    it 'creates work if the uuid is not used' do
      uuid = SecureRandom.uuid
      put :update, uuid: uuid, auth_token: user.auth_token,
                   name: 'hello',
                   model_id: product_model.id
      work = Work.last
      expect(response).to render_template('api/v3/works/show')
      expect(work.name).to eq('hello')
      expect(work.product).to eq(product_model)
      expect(work.user).to eq(user)
    end

    it 'updates work if the uuid is used' do
      put :update, uuid: work.uuid, auth_token: user.auth_token,
                   name: 'hello',
                   model_id: product_model.id
      work.reload
      expect(response).to render_template('api/v3/works/show')
      expect(work.name).to eq('hello')
      expect(work.product).to eq(product_model)
      expect(work.user).to eq(user)
    end

    it 'returns 422 if some params are invalid' do
      uuid = SecureRandom.uuid
      put :update, uuid: uuid, auth_token: user.auth_token,
                   name: '',
                   model_id: product_model.id
      expect(response.status).to eq(422)
      expect(Work.last).to be_nil
    end

    it 'updates user if work user is guest but current user is not' do
      guest_user = User.new_guest
      uuid = SecureRandom.uuid
      work = create(:work, user: guest_user)
      expect(work.user).to eq(guest_user)
      logged_in_user = create(:user)
      put :update, { uuid: uuid, auth_token: logged_in_user.auth_token,
                     name: 'hello',
                     model_id: product_model.id }, api_header(2)
      work = Work.last
      expect(work.user).to eq(logged_in_user)
    end

    # NOTE 在 find_or_initialize_work 時會因為找不到所以使用該 uuid 建立新 work -> 然後爆炸
    it 'returns 422 if work user and current user are not guest' do
      logged_in_user = create(:user)
      put :update, uuid: work.uuid, auth_token: logged_in_user.auth_token,
                   name: 'hello',
                   model_id: product_model.id
      work = Work.last
      expect(work.user).not_to eq(logged_in_user)
      expect(response.status).to eq(422)
    end
  end

  describe '#finish' do
    it 'finishes and returns the work' do
      post :finish, uuid: work.uuid, auth_token: user.auth_token
      work.reload
      expect(response).to render_template('api/v3/works/show')
      expect(Work.last).to be_finished
    end

    it 'returns 404 if the uuid is not used' do
      post :finish, uuid: 'what-the-fuck-y-u-give-a-wrong-uuid', auth_token: user.auth_token
      expect(response.status).to eq(404)
    end
  end
end
