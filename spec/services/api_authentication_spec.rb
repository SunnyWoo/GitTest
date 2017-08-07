require 'spec_helper'

RSpec.describe ApiAuthentication do
  Given(:api_params) do
    {
      provider: 'facebook',
      uid: "uid_#{rand(100_000)}",
      access_token: 'access_token',
      email: 'a_fb_user@facebook.com',
      secret: "secret#{rand(10_000)}"
    }
  end
  Given(:obj) { ApiAuthentication.new(api_params) }

  describe '#initialize' do
    Then { obj.instance_eval { @provider } == api_params[:provider] }
    And { obj.instance_eval { @uid } == api_params[:uid] }
    And { obj.instance_eval { @token } == api_params[:access_token] }
    And { obj.instance_eval { @email } == api_params[:email] }
    And { obj.instance_eval { @secret } == api_params[:secret] }
    And { obj.instance_eval { @user }.nil? }
  end

  describe '#user' do
    context 'when @user is set' do
      Given(:user) { create(:user) }
      When { obj.instance_variable_set(:@user, user) }
      Then { obj.user == user }
    end

    context 'when @user is not set, should verify Omniauth' do
      Given(:fb_user_hash) do
        {
          'id' => '100575323622317', 'first_name' => 'Will',
          'gender' => 'male', 'last_name' => 'Occhinoson',
          'link' => 'https://www.facebook.com/app_scoped_user_id/100575323622317/',
          'locale' => 'zh_TW', 'middle_name' => 'Alakiedhjded',
          'timezone' => 0, 'updated_time' => '2015-06-26T07:43:42+0000',
          'name' => 'Will Alakiedhjded Occhinoson', 'verified' => false
        }
      end
      Given(:url) { "https://graph.facebook.com/#{fb_user_hash['id']}/picture?width=999&height=999" }
      Given(:file) { "#{Rails.root}/spec/fixtures/test.jpg" }

      context 'when verified success' do
        When do
          expect(Omniauth).to receive(:verify).with(
            api_params[:provider], api_params[:access_token], api_params[:secret]
          ).and_return fb_user_hash
        end

        context 'create user when there is no users with correspondent email' do
          Given { stub_request(:get, 'https://graph.facebook.com/100575323622317/picture?height=999&width=999') }
          Then { expect { obj.user }.to change(User, :count).by(1) }
          And { obj.user.email == api_params[:email] }
          And { Omniauth.count == 1 }
        end

        context 'find the user when there is such user' do
          Given!(:user) { create :user, email: api_params[:email] }
          Given { stub_request(:get, 'https://graph.facebook.com/100575323622317/picture?height=999&width=999') }
          Then { expect { obj.user }.to_not change(User, :count) }
          And { Omniauth.count == 1 }
        end

        context 'when omniauth already there, just update it' do
          Given!(:omniauth) { create :omniauth, uid: api_params[:uid] }
          Then { expect { obj.user }.to_not change(Omniauth, :count) }
          And { omniauth.tap(&:reload).oauth_token == api_params[:access_token] }
        end
      end

      context 'when verified failed' do
        Given(:result) { { 'error' => 'Verified failed' } }
        When do
          expect(Omniauth).to receive(:verify).with(
            api_params[:provider], api_params[:access_token], api_params[:secret]
          ).and_return result
        end
        Then { obj.authenticated? == false }
      end
    end
  end

  describe '#authenticated?' do
    context 'return true when #user is a User' do
      Given(:user) { create(:user) }
      When { expect(obj).to receive(:user).and_return(user).at_least(:once) }
      Then { obj.authenticated? }
    end

    context 'return false when #user is nil' do
      When { expect(obj).to receive(:user).and_return(nil).at_least(:once) }
      Then { obj.authenticated? == false }
    end

    context 'return false when #user is other object' do
      When { expect(obj).to receive(:user).and_return(%w(1 2 3)).at_least(:once) }
      Then { obj.authenticated? == false }
    end
  end

  describe '#sign_in' do
    before { expect(obj).to receive(:user).and_return(user) }
    Given(:user) { spy(:user) }
    When { obj.sign_in }
    Then { expect(user).to have_received(:generate_token) }
  end

  describe 'REAL provider test' do
    context 'Facebook', slow: true do
      Given!(:fb_user) do
        Koala::Facebook::TestUsers.new(
          app_id: Settings.Facebook_app_id, secret: Settings.Facebook_secret
        ).create(true, 'offline_access,read_stream')
      end
      Given(:api_params) do
        {
          provider: 'facebook',
          uid: fb_user['id'],
          access_token: fb_user['access_token']
        }
      end
      Given(:omniauth) { Omniauth.last }
      Then { expect { obj.user }.to change(User, :count).by(1) }
      And { omniauth.oauth_token == api_params[:access_token] }
    end

    context 'twitter_user', :vcr do
      context 'successfully authed' do
        Given(:api_params) do
          {
            provider: 'twitter',
            access_token: '2204864839-YVZXx113PfQkhajAkMs5LqUmr1syoWRnRZnos2X',
            secret: 'iJlOvoxwCQo8qF4FgXl4YOfzcoFHdfFB9nEkt0im8fKLn',
            uid: '2204864839'
          }
        end
        Given(:omniauth) { Omniauth.last }
        Then { expect { obj.user }.to change(User, :count).by(1) }
        And { omniauth.oauth_token == api_params[:access_token] }
        And { omniauth.oauth_secret == api_params[:secret] }
        And { omniauth.uid == api_params[:uid] }
      end

      context 'failed' do
        Given(:api_params) do
          {
            provider: 'twitter',
            access_token: '2204864839asdasd-YVZXx113PfQkhajAkMs5LqUmr1syoWRnRZnos2X',
            secret: 'wrong_token',
            uid: '2204864839'
          }
        end
        Then { expect { obj.user }.to_not change(User, :count) }
        And { obj.error == 'Unauthorized' }
      end
    end

    context 'google_oauth2 user', :vcr do
      Given(:api_params) do
        {
          access_token: 'ya29.2wE9J0CU9Xmbu8RAeQ2FUwX_e7rlVOBEA0OyOO1-XwfoKm5QZuy4wvhBubTvLXFjuVXX',
          provider: 'google_oauth2', uid: '105589276471242548961'
        }
      end
      Given(:omniauth) { Omniauth.last }
      Then { expect { obj.user }.to change(User, :count).by(1) }
      And { omniauth.oauth_token == api_params[:access_token] }
      And { omniauth.uid == api_params[:uid] }
    end
  end
end
