require 'spec_helper'

describe Oauth2UserService, :vcr do
  describe '#excute' do
    context 'updates user and omniauth correctly' do
      it 'from facebook' do
        stub_request(:get, 'https://graph.facebook.com//picture?height=999&width=999')
        set_facebook_omniauth
        auth = OmniAuth.config.mock_auth[:facebook]
        omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
        omniauth.oauth_token = auth.credentials.token
        omniauth.oauth_secret = auth.credentials.secret
        auth.merge!(email: auth.info.email,
                    name: auth.info.name,
                    gender: 'male')
        user = Oauth2UserService.new(auth, omniauth, nil).execute
        expect(user.name).to eq auth.name
        expect(user.email).to eq auth.info.email
        expect(user.gender).to eq auth.gender
        expect(user.confirmed?).to be true
        expect(omniauth.reload.username).to eq auth.name
        expect(omniauth.provider).to eq auth.provider
        expect(omniauth.uid).to eq auth.uid.to_s
      end

      it 'from twitter' do
        set_twitter_omniauth
        auth = OmniAuth.config.mock_auth[:twitter]
        omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
        omniauth.oauth_token = auth.credentials.token
        omniauth.oauth_secret = auth.credentials.secret
        auth.merge!(name: auth.info.name, profile_location: 'Manchester U.K')
        user = Oauth2UserService.new(auth, omniauth, nil).execute
        expect(user.name).to eq auth.name
        expect(user.location).to eq auth.profile_location
        expect(user.confirmed?).to be true
        expect(omniauth.reload.username).to eq auth.name
        expect(omniauth.provider).to eq auth.provider
        expect(omniauth.uid).to eq auth.uid.to_s
      end

      it 'from google_oauth2' do
        set_google_omniauth
        auth = OmniAuth.config.mock_auth[:google_oauth2]
        omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
        omniauth.oauth_token = auth.credentials.token
        omniauth.oauth_secret = auth.credentials.secret
        auth.merge!(email: auth.info.email,
                    name: auth.info.name,
                    gender: 'male')
        user = Oauth2UserService.new(auth, omniauth, nil).execute
        expect(user.name).to eq auth.name
        expect(user.email).to eq auth.info.email
        expect(user.gender).to eq auth.gender
        expect(user.confirmed?).to be true
        expect(omniauth.reload.username).to eq auth.name
        expect(omniauth.provider).to eq auth.provider
        expect(omniauth.uid).to eq auth.uid.to_s
      end

      # google 先登入 建立 user
      # 在使用 Facebook 登入 同一個 user usrename 不會被Facebook username 取代
      it 'with facebook after google login' do
        stub_request(:get, 'https://graph.facebook.com//picture?height=999&width=999')
        set_google_omniauth
        auth = OmniAuth.config.mock_auth[:google_oauth2]
        omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
        omniauth.oauth_token = auth.credentials.token
        omniauth.oauth_secret = auth.credentials.secret
        auth.merge!(email: auth.info.email,
                    name: auth.info.name,
                    gender: 'male')
        user = Oauth2UserService.new(auth, omniauth, nil).execute
        expect(user.name).to eq('google commandp')

        set_facebook_omniauth
        auth = OmniAuth.config.mock_auth[:facebook]
        omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
        omniauth.oauth_token = auth.credentials.token
        omniauth.oauth_secret = auth.credentials.secret
        auth.merge!(email: auth.info.email,
                    name: auth.info.name,
                    gender: 'male')
        user = Oauth2UserService.new(auth, omniauth, nil).execute
        expect(user.omniauths.count).to eq(2)
        expect(user.omniauths.last.provider).to eq('facebook')
        expect(user.name).to eq('google commandp')
      end

      context 'from qq' do
        before { set_qq_omniauth }
        Given(:auth) do
          auth = OmniAuth.config.mock_auth[:qq]
          auth.merge!(figureurl_1: auth.info.image, nickname: auth.info.name)
        end
        Given(:omniauth) do
          omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
          omniauth.oauth_token = auth.credentials.token
          omniauth.oauth_secret = auth.credentials.secret
          omniauth
        end
        Given(:user) { Oauth2UserService.new(auth, omniauth, nil).execute }

        Then { user.name == auth.nickname }
        And { user.remote_avatar_url == auth.figureurl_1 }
        And { user.confirmed? == true }
        And { omniauth.reload.username == auth.info.name }
        And { omniauth.provider == auth.provider }
        And { omniauth.uid == auth.uid }
      end

      context 'from weibo' do
        before { set_weibo_omniauth }
        Given(:auth) do
          auth = OmniAuth.config.mock_auth[:weibo]
          auth.merge!(profile_image_url: auth.info.image, name: auth.info.name)
        end
        Given(:omniauth) do
          omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
          omniauth.oauth_token = auth.credentials.token
          omniauth.oauth_secret = auth.credentials.secret
          omniauth
        end
        Given(:user) { Oauth2UserService.new(auth, omniauth, nil).execute }

        Then { user.name == auth.info.name }
        And { user.remote_avatar_url == auth.info.image }
        And { user.confirmed? == true }
        And { omniauth.reload.username == auth.info.name }
        And { omniauth.provider == auth.provider }
        And { omniauth.uid == auth.uid }
      end

      context 'from wechat' do
        before { set_wechat_omniauth }
        Given(:auth) do
          auth = OmniAuth.config.mock_auth[:wechat]
          auth.merge!(headimgurl: auth.info.image, nickname: auth.info.name)
        end
        Given(:omniauth) do
          omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
          omniauth.oauth_token = auth.credentials.token
          omniauth.oauth_secret = auth.credentials.secret
          omniauth
        end
        Given(:user) { Oauth2UserService.new(auth, omniauth, nil).execute }

        Then { user.name == auth.info.name }
        And { user.remote_avatar_url == auth.info.image }
        And { user.confirmed? == true }
        And { omniauth.reload.username == auth.info.name }
        And { omniauth.provider == auth.provider }
        And { omniauth.uid == auth.uid }
      end
    end
  end
end
