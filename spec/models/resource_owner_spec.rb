require 'spec_helper'

describe ResourceOwner do
  describe '#from_assertion' do
    let(:valid_profile) do
      Hashie::Mash.new(
        'provider' => 'facebook',
        'uid' => '9',
        'info' => {
          'name' => 'ayaya',
          'image' => nil,
          'location' => 'Taiwan'
        },
        'credentials' => {
          'token' => 'sparkling-daydream'
        }
      )
    end

    context 'when using valid facebook access token' do
      before do
        expect(ResourceOwner).to receive(:get_profile_from_facebook).and_return(valid_profile)
      end

      context 'and user is signed up' do
        it 'updates auth with the token' do
          user = create(:user)
          create(:omniauth, provider: 'facebook', uid: '9', owner: user)

          ro = ResourceOwner.from_assertion('facebook', 'sparkling-daydream', nil, nil)
          expect(ro.user).to eq(user)
        end
      end
    end

    context 'when using invalid facebook access token' do
      before do
        expect(ResourceOwner).to receive(:get_profile_from_facebook).and_raise('invalid token')
      end

      it 'fails with error' do
        expect do
          ResourceOwner.from_assertion('facebook', 'sparkling-daydream', nil, nil)
        end.to raise_error
      end
    end
  end

  describe '#from_omniauth' do
    let(:valid_profile) do
      Hashie::Mash.new(
        'provider' => 'facebook',
        'uid' => '9',
        'info' => {
          'email' => 'same@email.com',
          'name' => 'ayaya',
          'image' => nil,
          'location' => 'Taiwan'
        },
        'credentials' => {
          'token' => 'sparkling-daydream'
        }
      )
    end

    context 'for China' do
      context 'when user is not bind' do
        before { stub_env('REGION', 'china') }
        it 'return need register when user id is nil' do
          expect do
            ResourceOwner.from_omniauth(valid_profile, 1231)
          end.to raise_error ActiveRecord::RecordNotFound
        end

        it 'return unbound when params user_id is nil' do
          expect do
            ResourceOwner.from_omniauth(valid_profile, nil)
          end.to raise_error UnboundError
        end

        it 'return need confirmed when user email is not confirmed and not same with provide email' do
          user = create(:user, :without_confirmed)
          expect do
            ResourceOwner.from_omniauth(valid_profile, user.id)
          end.to raise_error EmailUnconfirmedError
        end

        it 'bind_user when user email is same with provider email' do
          user = create(:user, :without_confirmed, email: 'same@email.com')
          create(:omniauth, provider: 'facebook', uid: '9', owner_id: nil)
          ro = ResourceOwner.from_omniauth(valid_profile, user.id)
          expect(ro.user).to eq(user)
        end

        it 'bind_user when user email is confirmed' do
          user = create(:user, email: 'another@email.com')
          create(:omniauth, provider: 'facebook', uid: '9', owner_id: nil)
          ro = ResourceOwner.from_omniauth(valid_profile, user.id)
          expect(ro.user).to eq(user)
        end
      end

      context 'when user is bound' do
        it 'creates auth and user model for the token' do
          user = create(:user)
          create(:omniauth, provider: 'facebook', uid: '9', owner: user)
          ro = ResourceOwner.from_omniauth(valid_profile, nil)
          expect(ro.user).to eq(user)
        end
      end
    end

    context 'for Global' do
      context 'when auth owner does exist' do
        it 'just returns the auth owner directly' do
          user = create :user
          create(:omniauth, provider: 'facebook', uid: '9', owner: user)
          resource_owner = ResourceOwner.from_omniauth(valid_profile, nil)
          expect(resource_owner.user).to eq(user)
        end
      end

      context 'when auth owner does not exist' do
        context 'and with user_id providerd' do
          let!(:user) { create :user }
          let!(:resource_owner) { ResourceOwner.from_omniauth(valid_profile, user.id) }

          it 'binds the auth with the user' do
            expect(resource_owner.user).to eq(user.reload)
          end

          it 'says that the auth owner must be confirmed' do
            expect(resource_owner.user).to be_confirmed
          end
        end

        context 'and without user_id provided' do
          let!(:resource_owner) { ResourceOwner.from_omniauth(valid_profile, nil) }

          it 'returns an fresh user just created by omniauth data' do
            expect(resource_owner.user).to be_a(User)
            expect(resource_owner.user.email).to eq valid_profile.info.email
            expect(resource_owner.user.name).to eq valid_profile.info.name
          end

          it 'says that the auth owner must be confirmed' do
            expect(resource_owner.user).to be_confirmed
          end
        end
      end
    end

    context 'when auth owner does not exist and provider is not in User::GLOBAL_PROVIDERS ' do
      it 'raises error OauthProviderMissingError in global area' do
        valid_profile.provider = 'forcebook'
        expect { ResourceOwner.from_omniauth(valid_profile, nil) }.to raise_error OauthProviderMissingError
      end
    end

    context 'when auth owner does exist, and who is unconfirmed for all area' do
      it 'raises error EmailUnconfirmedError' do
        user = create(:user, :without_confirmed)
        create(:omniauth, provider: 'facebook', uid: '9', owner: user)
        expect { ResourceOwner.from_omniauth(valid_profile, user.id) }.to raise_error EmailUnconfirmedError
      end
    end
  end

  describe '#get_profile_from_qq' do
    context 'access_token is valid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_qq, 'BA4D3E48D8EC4238CF01CDE942567085') }
      Then { profile.provider == 'qq' }
      And { profile.info.name == '三' }
      And { profile.uid == '4CEB92554772C935D4812517AABDA5D1' }
    end

    context 'access_token is invalid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_qq, 'error_token') }
      Then { raise_error(RuntimeError) }
    end
  end

  describe '#get_qq_openid' do
    context 'access_token is valid', :vcr do
      Given(:qq_access_token) { ResourceOwner.send(:qq_access_token, 'BA4D3E48D8EC4238CF01CDE942567085') }

      When(:openid) { ResourceOwner.send(:get_qq_openid, qq_access_token) }
      Then { openid == '4CEB92554772C935D4812517AABDA5D1' }
    end

    context 'access_token is invalid', :vcr do
      When(:profile) { ResourceOwner.send(:get_qq_openid, 'error_token') }
      Then { raise_error(RuntimeError) }
    end
  end

  describe '#generate_qq_profile' do
    context 'params is valid' do
      Given(:access_token) { ResourceOwner.send(:qq_access_token, 'token') }
      Given(:openid) { 'qq_openid' }
      Given(:raw_info) { { 'nickname' => 'qq_name', 'figureurl_1' => 'url_1' } }

      When(:result) { ResourceOwner.send(:generate_qq_profile, access_token, raw_info, openid) }
      Then { result.provider == 'qq' }
      And { result.uid == 'qq_openid' }
      And { result.info.name == 'qq_name' }
      And { result.info.image == 'url_1' }
      And { result.credentials.token == 'token' }
    end
  end

  describe '#get_profile_from_weibo' do
    context 'access_token is valid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_weibo, '2.002m9X_EMucQmCc31f256a089RjSzD') }
      Then { profile.provider == 'weibo' }
      And { profile.info.name == '老三_14874' }
      And { profile.uid.to_s == '3953257165' }
    end

    context 'access_token is invalid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_weibo, 'error_token') }
      Then { raise_error }
    end
  end

  describe '#get_weibo_uid' do
    context 'access_token is valid', :vcr do
      Given(:weibo_access_token) { ResourceOwner.send(:weibo_access_token, '2.002m9X_EMucQmCc31f256a089RjSzD') }

      When(:uid) { ResourceOwner.send(:get_weibo_uid, weibo_access_token) }
      Then { uid.to_s == '3953257165' }
    end

    context 'access_token is invalid', :vcr do
      When(:profile) { ResourceOwner.send(:get_weibo_uid, 'error_token') }
      Then { raise_error }
    end
  end

  describe '#generate_weibo_profile' do
    context 'params is valid' do
      Given(:access_token) { ResourceOwner.send(:weibo_access_token, 'token') }
      Given(:uid) { 'weibo_uid' }
      Given(:raw_info) { { 'name' => 'weibo_name', 'profile_image_url' => 'url_1' } }

      When(:result) { ResourceOwner.send(:generate_weibo_profile, access_token, raw_info, uid) }
      Then { result.provider == 'weibo' }
      And { result.uid == 'weibo_uid' }
      And { result.info.name == 'weibo_name' }
      And { result.info.image == 'url_1' }
      And { result.credentials.token == 'token' }
    end
  end

  describe '#get_profile_from_wechat' do
    context 'access_token is valid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_wechat, 'OezXcEiiBSKSxW', 'osFwTuFLvlJLF') }
      Then { profile.provider == 'wechat' }
      And { profile.info.name == '三' }
      And { profile.uid == 'o0XC3wSclYL201a1VXdAAm1gQeI0' }
    end

    context 'access_token is invalid', :vcr do
      When(:profile) { ResourceOwner.send(:get_profile_from_wechat, 'error_token') }
      Then { raise_error(RuntimeError) }
    end
  end

  describe '#generate_wechat_profile' do
    context 'params is valid' do
      Given(:access_token) { ResourceOwner.send(:wechat_access_token, 'token') }
      Given(:openid) { 'wechat_openid' }
      Given(:raw_info) { { 'nickname' => 'wechat_name', 'headimgurl' => 'url_1', 'unionid' => 'unionid' } }

      When(:result) { ResourceOwner.send(:generate_wechat_profile, access_token, raw_info) }
      Then { result.provider == 'wechat' }
      And { result.uid == 'unionid' }
      And { result.info.name == 'wechat_name' }
      And { result.info.image == 'url_1' }
      And { result.credentials.token == 'token' }
    end
  end
end
