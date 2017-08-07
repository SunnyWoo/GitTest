require 'spec_helper'

describe Api::V3::ProfilesController, :api_v3, type: :controller do
  describe 'GET /me' do
    context 'when a user signed in', signed_in: :normal do
      it 'returns current user data' do
        get :show, access_token: token.token, format: :json
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    context 'when a user did not sign in', signed_in: false do
      it 'returns current user data' do
        get :show, access_token: token.token
        expect(response.status).to eq(403)
      end
    end

    context 'when a user is just a guest', signed_in: :guest do
      it 'returns current user data' do
        get :show, access_token: token.token
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'PATCH /me/touch' do
    context 'when app has scope "touch_user"', signed_in: :normal do
      let(:scope) { 'touch_user' }

      it 'returns current user data with new updated_at' do
        patch :touch, access_token: token.token
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    context 'when app has no scope "touch_user"', signed_in: :normal do
      it 'raises 403 forbidden' do
        patch :touch, access_token: token.token
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'PATCH /me' do
    context 'when user signs in', signed_in: :normal do
      context 'returns ok with correct params' do
        Given(:data) do
          { name: 'Yoda', location: 'death planet', gender: 'unspecified',
            first_name: 'Angel', last_name: 'Fan', mobile_country_code: '018', birthday: '2000-1-1' }
        end
        When { patch :update, data.merge(access_token: access_token) }
        Then { response.status == 200 }
        And { expect(response).to render_template(:show) }
      end

      context 'returns 422 with incorrect params' do
        Given(:data) { { email: 'wtf.html.not.email.type' } }
        When { patch :update, data.merge(access_token: access_token) }
        Then { response.status == 422 }
      end
    end

    context 'when user does not sign in', signed_in: false do
      context 'returns 403' do
        Given(:data) { { name: 'Yoda', location: 'death planet', gender: 'unspecified' } }
        When { patch :update, data.merge(access_token: access_token) }
        Then { response.status == 403 }
      end
    end
  end

  describe 'PATCH /me/avatar' do
    context 'when user signs in', signed_in: :normal do
      context 'returns ok with correct params' do
        Then { expect(user.avatar.url).to match('img_fbdefault') }
        Given(:file) { fixture_file_upload('test.jpg', 'image/jpeg') }
        When { patch :upload_avatar, file: file, access_token: access_token }
        Then { response.status == 200 }
        And { expect(user.tap(&:reload).avatar.url).not_to match('img_fbdefault') }
        And { expect(response).to render_template(:show) }
      end

      context 'returns ok with avatar_aid' do
        Then { expect(user.avatar.url).to match('img_fbdefault') }
        Given!(:attachment) { create(:attachment) }
        When { patch :upload_avatar, avatar_aid: attachment.aid, access_token: access_token }
        Then { response.status == 200 }
        And { expect(user.tap(&:reload).avatar.url).not_to match('img_fbdefault') }
        And { expect(response).to render_template(:show) }
      end

      context 'return error without file or avatar_aid' do
        When { patch :upload_avatar, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'InvalidError' }
      end
    end

    context 'when user does not sign in', signed_in: false do
      context 'returns 403' do
        Given(:file) { fixture_file_upload('test.jpg', 'image/jpeg') }
        When { patch :upload_avatar, file: file, access_token: access_token }
        Then { response.status == 403 }
      end
    end
  end
end
