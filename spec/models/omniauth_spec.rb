# == Schema Information
#
# Table name: omniauths
#
#  id               :integer          not null, primary key
#  provider         :string(255)
#  uid              :string(255)
#  oauth_token      :text
#  oauth_expires_at :datetime
#  owner_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  email            :string(255)
#  username         :string(255)
#  owner_type       :string(255)
#  oauth_secret     :string(255)
#

require 'spec_helper'

describe Omniauth do
  it 'FactoryGirl' do
    expect(build(:omniauth)).to be_valid
  end

  it { should belong_to(:owner) }

  [:uid, :oauth_token, :provider].each do |attr|
    it { should validate_presence_of(attr) }
  end

  describe '.authenticate' do
    context 'when provider is not support' do
      it 'fails' do
        expect { Omniauth.authenticate('whatever', 'foo', 'bar') }.to raise_error(NoMethodError)
      end
    end

    context 'when provider is facebook' do
      context 'and token is valid' do
        it 'returns auth' do
          expect(Omniauth).to receive(:verify_facebook).and_return('id' => '100')
          auth = Omniauth.authenticate('facebook', 'foo')
          expect(auth.provider).to eq('facebook')
          expect(auth.uid).to eq('100')
          expect(auth.oauth_token).to eq('foo')
        end
      end

      context 'and token is invalid' do
        it 'fails' do
          expect { Omniauth.authenticate('facebook', 'foo') }.to raise_error(WebMock::NetConnectNotAllowedError)
        end
      end
    end

    context 'when provider is twitter' do
      context 'and token is valid' do
        it 'returns auth' do
          expect(Omniauth).to receive(:verify_twitter).and_return('id' => '100')
          auth = Omniauth.authenticate('twitter', 'foo', 'bar')
          expect(auth.provider).to eq('twitter')
          expect(auth.uid).to eq('100')
          expect(auth.oauth_token).to eq('foo')
          expect(auth.oauth_secret).to eq('bar')
        end
      end

      context 'and token is invalid' do
        it 'fails' do
          expect { Omniauth.authenticate('twitter', 'foo', 'bar') }.to raise_error(WebMock::NetConnectNotAllowedError)
        end
      end
    end

    context 'when provider is google_oauth2' do
      context 'and token is valid' do
        it 'returns auth' do
          expect(Omniauth).to receive(:verify_google_oauth2).and_return('sub' => '100')
          auth = Omniauth.authenticate('google_oauth2', 'foo')
          expect(auth.provider).to eq('google_oauth2')
          expect(auth.uid).to eq('100')
          expect(auth.oauth_token).to eq('foo')
        end
      end

      context 'and token is invalid' do
        it 'fails' do
          expect { Omniauth.authenticate('google_oauth2', 'foo') }.to raise_error(WebMock::NetConnectNotAllowedError)
        end
      end
    end

    context 'when provider is google_oauth2' do
      context 'and token is valid' do
        before { allow(Omniauth).to receive(:verify_qq).and_return('id' => '100') }
        Given(:auth) { Omniauth.authenticate('qq', 'foo') }

        Then { auth.provider == 'qq' }
        Then { auth.uid == '100' }
        Then { auth.oauth_token == 'foo' }
      end

      context 'and token is invalid' do
        When(:profile) { Omniauth.authenticate('qq', 'foo') }
        Then { raise_error }
      end
    end
  end

  describe '#verify_qq' do
    context 'access_token is valid', :vcr do
      When(:verify_qq) { Omniauth.verify_qq('BA4D3E48D8EC4238CF01CDE942567085') }
      Then { verify_qq['nickname'] == '三' }
    end

    context 'access_token is invalid', :vcr do
      When(:verify_qq) { Omniauth.verify_qq('error_token') }
      Then { raise_error }
    end
  end

  describe '#get_qq_openid' do
    context 'access_token is valid', :vcr do
      Given(:qq_access_token) { Omniauth.qq_access_token('BA4D3E48D8EC4238CF01CDE942567085') }

      When(:openid) { Omniauth.get_qq_openid(qq_access_token) }
      Then { openid == '4CEB92554772C935D4812517AABDA5D1' }
    end

    context 'access_token is invalid', :vcr do
      When(:openid) { Omniauth.get_qq_openid('error_token') }
      Then { raise_error }
    end
  end

  describe '#qq_access_token' do
    context 'access_token is valid' do
      Given(:qq_access_token) { Omniauth.qq_access_token('BA4D3E48D8EC4238CF01CDE942567085') }

      Then { qq_access_token.token == 'BA4D3E48D8EC4238CF01CDE942567085' }
    end
  end

  describe '#verify_weibo' do
    context 'access_token is valid', :vcr do
      When(:verify_weibo) { Omniauth.verify_weibo('2.002m9X_EMucQmCc31f256a089RjSzD') }
      Then { verify_weibo['name'] == '老三_14874' }
    end

    context 'access_token is invalid', :vcr do
      When(:verify_weibo) { Omniauth.verify_weibo('error_token') }
      Then { raise_error }
    end
  end

  describe '#get_weibo_uid' do
    context 'access_token is valid', :vcr do
      Given(:weibo_access_token) { Omniauth.weibo_access_token('2.002m9X_EMucQmCc31f256a089RjSzD') }

      When(:uid) { Omniauth.get_weibo_uid(weibo_access_token) }
      Then { uid.to_s == '3953257165' }
    end

    context 'access_token is invalid', :vcr do
      When(:uid) { Omniauth.get_weibo_uid('error_token') }
      Then { raise_error }
    end
  end

  describe '#weibo_access_token' do
    context 'access_token is valid' do
      Given(:weibo_access_token) { Omniauth.weibo_access_token('2.002m9X_EMucQmCc31f256a089RjSzD') }

      Then { weibo_access_token.token == '2.002m9X_EMucQmCc31f256a089RjSzD' }
    end
  end

  describe '#verify_wechat' do
    context 'access_token is valid', :vcr do
      When(:verify_wechat) do
        Omniauth.verify_wechat('OezXcEiiBSKSxW0eoylIeBTpHEUOchDk',
                               'oN01fwuX0-M1-V4odxHO_KwNVKdQ')
      end
      Then { verify_wechat['nickname'] == 'devon' }
    end

    context 'access_token is invalid', :vcr do
      When(:verify_wechat) { Omniauth.verify_wechat('error_token') }
      Then { raise_error }
    end
  end

  describe '#wechat_access_token' do
    context 'access_token is valid' do
      Given(:wechat_access_token) { Omniauth.wechat_access_token('OezXcEiiBSKSxW0eoylIeBTpHEUOchDk') }

      Then { wechat_access_token.token == 'OezXcEiiBSKSxW0eoylIeBTpHEUOchDk' }
    end
  end

  describe '#create_owner' do
    context 'do not confirm the owner' do
      Given(:omniauth) do
        Omniauth.create(provider:    'twitter',
                        uid:         'hoolilike',
                        oauth_token: 'Pied Piper')
      end
      Given(:auth) do
        set_twitter_omniauth
        OmniAuth.config.mock_auth[:twitter]
      end
      When { omniauth.create_owner(auth) }
      Then { User.last.confirmed? }
    end

    context 'when email already have user' do
      let!(:user) { create(:user, email: 'dev@commandp.com')}
      Given(:omniauth) do
        Omniauth.create(provider:    'facebook',
                        uid:         '1234567',
                        oauth_token: 'ABCDEF')
      end
      Given(:auth) do
        set_facebook_omniauth
        OmniAuth.config.mock_auth[:facebook]
      end
      When { auth.info.email == user.email }
      When { omniauth.create_owner(auth) }
      When { omniauth.reload }
      Then { omniauth.owner.confirmed? }
      Then { omniauth.owner.email == user.email }
      Then { omniauth.owner.id == user.id }
    end
  end

  describe '#bind_owner' do
    Given(:omniauth) do
      Omniauth.create(provider:    'facebook',
                      uid:         '1234567',
                      oauth_token: 'ABCDEF')
    end
    Given(:auth) do
      set_google_omniauth
      OmniAuth.config.mock_auth[:google_oauth2]
    end
    Given(:token) { create(:access_token, resource_owner_id: user.id, scopes: 'public') }

    context 'bind owner' do
      Given(:user) { create :user, :without_confirmed, name: nil }

      When { omniauth.bind_owner(auth, user.id) }
      When { user.reload }
      Then { user.location == auth.info.location }
      And { user.name == auth.info.name }
      And { user.confirmed? == false }
    end

    context 'skip confirmed when user email is same with facebook' do
      Given(:user) { create :user, :without_confirmed, name: nil, email: 'dev@commandp.com' }

      When { omniauth.bind_owner(auth, user.id) }
      When { user.reload }
      Then { user.confirmed? == true }
    end
  end
end
