require 'spec_helper'

describe TokensController, type: :controller do
  describe 'client credentials grant flow' do
    let!(:application) { create(:application) }

    it 'returns token' do
      post :create, grant_type: 'client_credentials',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public'
      expect(response.status).to eq(200)
      token = JSON.parse(response.body)
      expect(token).to have_key('access_token')
      expect(token['scope']).to eq('public')
    end
  end

  describe 'password grant flow' do
    let!(:application) { create(:application) }
    let(:mobile) { '18626058997' }
    let(:user) { create :user, mobile: mobile }

    it 'returns token' do
      post :create, grant_type: 'password',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public',
                    login: user.email,
                    password: user.password
      expect(response.status).to eq(200)
      token = JSON.parse(response.body)
      expect(token).to have_key('access_token')
      expect(token['scope']).to eq('public')
    end

    it 'returns error in the formatted style with invalid params' do
      post :create, grant_type: 'password',
                    client_id: 'application.uid.yoyo',
                    client_secret: application.secret,
                    scope: 'public',
                    login: user.email,
                    password: user.password
      expect(response.status).to eq(401)
      expect(response_json).to have_key('code')
      expect(response_json).to have_key('error')
    end

    it 'returns token when login is mobile' do
      post :create, grant_type: 'password',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public',
                    login: mobile,
                    password: user.password
      expect(response.status).to eq(200)
      token = JSON.parse(response.body)
      expect(token).to have_key('access_token')
      expect(token['scope']).to eq('public')
    end

    it 'returns errors when email is unconfirmed' do
      unconfirmed_user = create :user, :without_confirmed
      post :create, grant_type: 'password',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public',
                    login: unconfirmed_user.email,
                    password: unconfirmed_user.password
      expect(response.status).to eq(401)
      token = JSON.parse(response.body)
      expect(token['code']).to eq('EmailUnconfirmed')
    end

    it 'returns errors when password is wrong' do
      post :create, grant_type: 'password',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public',
                    login: user.email,
                    password: 'user.password_yaya'
      expect(response.status).to eq(401)
      token = JSON.parse(response.body)
      expect(token['code']).to eq('InvalidLoginInfo')
    end

    it 'returns errors when email is wrong' do
      post :create, grant_type: 'password',
                    client_id: application.uid,
                    client_secret: application.secret,
                    scope: 'public',
                    login: 'user.email_yaya',
                    password: 'user.password_yaya'
      expect(response.status).to eq(401)
      token = JSON.parse(response.body)
      expect(token['code']).to eq('InvalidLoginInfo')
    end

    context 'guest to user' do
      it 'returns token and migrate guest to user when old_access_token is valid' do
        guest = User.new_guest
        guest_token = create(:access_token, resource_owner_id: guest.id, scopes: 'public')

        post :create, grant_type: 'password',
                      client_id: application.uid,
                      client_secret: application.secret,
                      scope: 'public',
                      login: user.email,
                      password: user.password,
                      old_access_token: guest_token.token

        expect(response.status).to eq(200)
        token = JSON.parse(response.body)
        expect(token).to have_key('access_token')
        expect(token['scope']).to eq('public')
        expect(guest.tap(&:reload).role).to eq('die')
        expect(guest.migrate_to_user_id.to_i).to eq(User.last.id)
      end

      it 'return token when old_access_token is invalid' do
        post :create, grant_type: 'password',
                      client_id: application.uid,
                      client_secret: application.secret,
                      scope: 'public',
                      login: user.email,
                      password: user.password,
                      old_access_token: 'xxx'
        expect(response.status).to eq(200)
        token = JSON.parse(response.body)
        expect(token).to have_key('access_token')
        expect(token['scope']).to eq('public')
        expect(User.where("profile->'migrate_to_user_id'='#{User.last.id}'").count).to eq(0)
      end
    end
  end

  describe 'assertion grant flow' do
    let!(:application) { create(:application) }

    context 'when 3rd party token is valid' do
      it 'returns token' do
        user = create(:user)
        expect(ResourceOwner).to receive(:from_assertion).and_return(ResourceOwner.new(user.id))

        post :create, grant_type: 'assertion',
                      client_id: application.uid,
                      client_secret: application.secret,
                      assertion_type: 'provider',
                      assertion_token: 'provider access token',
                      assertion_secret: 'provider secret',
                      scope: 'public'
        expect(response.status).to eq(200)
        token = JSON.parse(response.body)
        expect(token).to have_key('access_token')
        expect(token).to have_key('refresh_token')
        expect(token['scope']).to eq('public')
      end

      it 'returns 401' do
        expect(ResourceOwner).to receive(:from_assertion).and_raise EmailUnconfirmedError

        post :create, grant_type: 'assertion',
                      client_id: application.uid,
                      client_secret: application.secret,
                      assertion_type: 'provider',
                      assertion_token: 'provider access token',
                      assertion_secret: 'provider secret',
                      scope: 'public'
        expect(response.status).to eq(401)
        token = JSON.parse(response.body)
        expect(token['code']).to eq('EmailUnconfirmed')
      end

      context 'guest to user' do
        it 'returns token and migrate guest to user when old_access_token is valid' do
          user = create(:user)
          expect(ResourceOwner).to receive(:from_assertion).and_return(ResourceOwner.new(user.id))
          guest = User.new_guest
          guest_token = create(:access_token, resource_owner_id: guest.id, scopes: 'public')

          post :create, grant_type: 'assertion',
                        client_id: application.uid,
                        client_secret: application.secret,
                        assertion_type: 'provider',
                        assertion_token: 'provider access token',
                        assertion_secret: 'provider secret',
                        scope: 'public',
                        old_access_token: guest_token.token
          expect(response.status).to eq(200)
          token = JSON.parse(response.body)
          expect(token).to have_key('access_token')
          expect(token).to have_key('refresh_token')
          expect(token['scope']).to eq('public')
          expect(guest.tap(&:reload).role).to eq('die')
          expect(guest.migrate_to_user_id.to_i).to eq(user.id)
        end

        it 'return token when old_access_token is invalid' do
          user = create(:user)
          expect(ResourceOwner).to receive(:from_assertion).and_return(ResourceOwner.new(user.id))
          post :create, grant_type: 'assertion',
                        client_id: application.uid,
                        client_secret: application.secret,
                        assertion_type: 'provider',
                        assertion_token: 'provider access token',
                        assertion_secret: 'provider secret',
                        scope: 'public',
                        old_access_token: 'xxx'
          expect(response.status).to eq(200)
          token = JSON.parse(response.body)
          expect(token).to have_key('access_token')
          expect(token['scope']).to eq('public')
          expect(User.where("profile->'migrate_to_user_id'='#{user.id}'").count).to eq(0)
        end
      end
    end

    context 'when 3rd party token is invalid' do
      it 'raises error' do
        expect(ResourceOwner).to receive(:from_assertion).and_raise('invalid token')

        post :create, grant_type: 'assertion',
                      client_id: application.uid,
                      client_secret: application.secret,
                      assertion_type: 'provider',
                      assertion_token: 'provider access token',
                      assertion_secret: 'provider secret',
                      scope: 'public'
        expect(response.status).to eq(401)
      end
    end

    context 'when type is guest' do
      it 'creates guest user and returns token' do
        post :create, grant_type: 'assertion',
                      client_id: application.uid,
                      client_secret: application.secret,
                      assertion_type: 'guest',
                      scope: 'public'
        expect(response.status).to eq(200)
        token = JSON.parse(response.body)
        expect(token).to have_key('access_token')
        expect(token).to have_key('refresh_token')
        expect(token['scope']).to eq('public')
        expect(User.last).to be_guest
      end
    end
  end
end
