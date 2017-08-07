require 'spec_helper'

describe OmniauthUserService do
  describe '#excute' do
    Given(:user) do
      User.where(email: auth.info.email || 'guest_gg@commandp.me').first_or_initialize.tap do |user|
        user.password = Devise.friendly_token[0, 10] if user.new_record?
      end
    end
    Given(:file) { "#{Rails.root}/spec/fixtures/test.jpg" }
    context 'updates user and omniauth correctly' do
      Given(:omniauth) do
        Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize.tap do |omniauth|
          omniauth.oauth_token = auth.credentials.token
          omniauth.oauth_secret = auth.credentials.secret
          stub_request(:get, "https://graph.facebook.com/#{auth.uid}/picture?width=999&height=999")
        end
      end
      Given(:url) { auth['info']['image'] }
      When { OmniauthUserService.new(auth, user, omniauth).execute }

      context 'with facebook' do
        Given(:auth) do
          set_facebook_omniauth
          OmniAuth.config.mock_auth[:facebook]
        end
        Given(:url) { "https://graph.facebook.com/#{auth.uid}/picture?width=999&height=999" }
        Then do
          expect(user.reload.name).to eq 'facebook commandp'
          expect(omniauth.reload.username).to eq 'facebook commandp'
          expect(user.email).to eq auth.info.email
          expect(omniauth.provider).to eq auth.provider
          expect(omniauth.uid).to eq auth.uid.to_s
        end
      end

      context 'with twitter' do
        Given(:auth) do
          set_twitter_omniauth
          OmniAuth.config.mock_auth[:twitter]
        end
        Then do
          expect(user.reload.name).to eq 'twitter commandp'
          expect(omniauth.reload.username).to eq 'twitter commandp'
          expect(user.email).to eq 'guest_gg@commandp.me'
          expect(omniauth.provider).to eq auth.provider
          expect(omniauth.uid).to eq auth.uid.to_s
        end
      end

      context 'with weibo' do
        Given(:auth) do
          set_weibo_omniauth
          OmniAuth.config.mock_auth[:weibo]
        end
        Then do
          expect(user.reload.name).to eq 'weibo commandp'
          expect(omniauth.reload.username).to eq 'weibo commandp'
          expect(user.email).to eq 'guest_gg@commandp.me'
          expect(omniauth.provider).to eq auth.provider
          expect(omniauth.uid).to eq auth.uid.to_s
        end
      end

      context 'with google' do
        Given(:auth) do
          set_google_omniauth
          OmniAuth.config.mock_auth[:google_oauth2]
        end
        Then do
          expect(user.reload.name).to eq 'google commandp'
          expect(omniauth.reload.username).to eq 'google commandp'
          expect(user.email).to eq auth.info.email
          expect(omniauth.provider).to eq auth.provider
          expect(omniauth.uid).to eq auth.uid.to_s
        end
      end

      # google 先登入 建立 user
      # 在使用 Facebook 登入 同一個 user usrename 不會被Facebook username 取代
      context 'with facebook after google login' do
        Given(:auth) do
          set_google_omniauth
          OmniAuth.config.mock_auth[:google_oauth2]
        end
        Then do
          expect(user.reload.name).to eq 'google commandp'
          expect(omniauth.uid).to eq auth.uid.to_s

          set_facebook_omniauth
          auth = OmniAuth.config.mock_auth[:facebook]
          stub_request(:get, "https://graph.facebook.com/#{auth.uid}/picture?width=999&height=999")
          User.from_omniauth(auth, user)

          expect(user.reload.name).to eq 'google commandp'
          expect(user.omniauths.count).to eq(2)
          expect(user.omniauths.last.provider).to eq('facebook')
        end
      end

      context 'with qq' do
        Given(:auth) do
          set_qq_omniauth
          OmniAuth.config.mock_auth[:qq]
        end
        Then do
          expect(user.reload.name).to eq 'qq commandp'
          expect(omniauth.reload.username).to eq 'qq commandp'
          expect(user.email).to eq 'guest_gg@commandp.me'
          expect(omniauth.provider).to eq auth.provider
          expect(omniauth.uid).to eq auth.uid.to_s
        end
      end
    end

    context 'raises error when auth content is insufficient' do
      Given(:auth) do
        set_not_enough_info_omniauth
        OmniAuth.config.mock_auth[:google_oauth2]
      end
      Given(:omniauth) { Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize }
      Then { expect { OmniauthUserService.new(auth, user, omniauth).execute }.to raise_error }
    end
  end
end
