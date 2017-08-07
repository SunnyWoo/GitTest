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

class Omniauth < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, autosave: true

  validates :provider, :uid, :oauth_token, presence: true

  validates_associated :owner

  GLOBAL_PROVIDERS = %w(facebook twitter google_oauth2)

  def bind_owner(data, user_id)
    user = User.find(user_id)
    user.name ||= data.info.name
    user.remote_avatar_url ||= data.info.image
    user.location ||= data.info.location
    user.skip_confirmation! if data.info.email == user.email
    user.save!
    update(owner: user)
  end

  def create_owner(data)
    email = data.info.email || User.random_email
    user = User.where(email: email).first_or_initialize
    if user.new_record?
      user.skip_confirmation!
      user.password = SecureRandom.urlsafe_base64
    end
    user.name ||= data.info.name
    user.remote_avatar_url ||= data.info.image
    user.location ||= data.info.location
    user.confirmed_at ||= Time.zone.now
    update(owner: user) if user.save
  end

  ID_COLUMN = {
    'facebook' => 'id',
    'twitter' => 'id',
    'google_oauth2' => 'sub',
    'qq' => 'id',
    'weibo' => 'id',
    'wechat' => 'id'
  }

  class << self
    def authenticate(provider, access_token, secret = nil)
      profile = send("verify_#{provider}", access_token, secret)
      id = profile[ID_COLUMN[provider]]
      Omniauth.find_or_initialize_by(provider: provider, uid: id).tap do |auth|
        auth.update(oauth_token: access_token, oauth_secret: secret)
      end
    end

    def verify(provider, access_token, secret = nil)
      case provider
      when 'facebook'
        verify_facebook(access_token)
      when 'twitter'
        verify_twitter(access_token, secret)
      when 'google_oauth2'
        verify_google_oauth2(access_token)
      when 'qq'
        verify_qq(access_token)
      when 'weibo'
        verify_weibo(access_token)
      when 'wechat'
        verify_wechat(access_token, secret)
      else
        fail OauthProviderMissingError, caused_by: provider
      end
    end

    def verify_facebook(access_token, _ = nil)
      client = OAuth2::Client.new(Settings.Facebook_app_id,
                                  Settings.Facebook_secret,
                                  site: 'https://graph.facebook.com',
                                  authorize_url: 'https://www.facebook.com/dialog/oauth',
                                  token_url: 'oauth/access_token')
      access_token = OAuth2::AccessToken.new(client, access_token)
      access_token.get('me').parsed
    end

    def verify_twitter(access_token, secret)
      consumer = OAuth::Consumer.new(Settings.twitter.api_key,
                                     Settings.twitter.secret,
                                     authorize_path: '/oauth/authenticate',
                                     site: 'https://api.twitter.com')
      access_token = OAuth::AccessToken.new(consumer, access_token, secret)
      response = access_token.get('/1.1/account/verify_credentials.json?include_entities=false&skip_status=true')
      response.value # it raises error if not 2xx
      JSON.parse(response.body)
    end

    # return example
    #    {
    #      "id" => "105239276471242548961",
    #      "email" => "m.wang@gmail.com",
    #      "verified_email" => true,
    #      "name" => "王大明",
    #      "given_name" => "大明",
    #      "family_name" => "王",
    #      "link" => "https://plus.google.com/+王大明",
    #      "picture" => "https://lh4.googleusercontent.com/-QvMD4CUCekI/AAAAAAAAAAI/AAAAAAAAy6s/_B6aWehKGwU/photo.jpg",
    #      "gender" => "male",
    #      "locale" => "zh-TW"
    #    }
    def verify_google_oauth2(access_token, _ = nil)
      client = OAuth2::Client.new(Settings.google.app_id,
                                  Settings.google.secret,
                                  site:          'https://accounts.google.com',
                                  authorize_url: '/o/oauth2/auth',
                                  token_url:     '/o/oauth2/token')
      user_info = OAuth2::AccessToken.new(client, access_token)
      user_info.get('https://www.googleapis.com/oauth2/v2/userinfo').parsed
    end

    def verify_qq(access_token, _ = nil)
      access_token = qq_access_token(access_token)
      openid = get_qq_openid(access_token)
      openid_params = { openid: openid, oauth_consumer_key: Settings.qq.app_id, format: :json }
      access_token.get('/user/get_user_info', params: openid_params, parse: :json).parsed
    end

    def qq_access_token(access_token)
      client = OAuth2::Client.new(Settings.qq.app_id,
                                  Settings.qq.app_key,
                                  site:          'https://graph.qq.com',
                                  authorize_url: '/oauth2.0/authorize',
                                  token_url:     '/oauth2.0/token')
      OAuth2::AccessToken.new(client, access_token)
    end

    def get_qq_openid(access_token)
      access_token.options[:mode] = :query
      response = access_token.get('/oauth2.0/me')
      matched = response.body.match(/"openid":"(?<openid>\w+)"/)
      if matched.present?
        matched[:openid]
      else
        fail 'The access token is invalid'
      end
    end

    def verify_weibo(access_token, _ = nil)
      access_token = weibo_access_token(access_token)
      uid = get_weibo_uid(access_token)
      access_token.get('/2/users/show.json', params: { uid: uid }).parsed
    end

    def weibo_access_token(access_token)
      client = OAuth2::Client.new(Settings.weibo.api_key,
                                  Settings.weibo.secret,
                                  site:          'https://api.weibo.com',
                                  authorize_url: '/oauth2/authorize',
                                  token_url:     '/oauth2/access_token')
      OAuth2::AccessToken.new(client, access_token)
    end

    def get_weibo_uid(access_token)
      access_token.options[:mode] = :query
      access_token.options[:param_name] = 'access_token'
      uid = access_token.get('/2/account/get_uid.json').parsed['uid']
      if uid.present?
        uid
      else
        fail 'The access token is invalid'
      end
    end

    def verify_wechat(access_token, openid = nil)
      access_token = wechat_access_token(access_token)
      access_token.options[:mode] = :query
      JSON access_token.get('/sns/userinfo', params: { openid: openid }).parsed
    end

    def wechat_access_token(access_token)
      client = OAuth2::Client.new(Settings.wechat.app_id,
                                  Settings.wechat.app_secret,
                                  site:          'http://api.weixin.qq.com',
                                  authorize_url: 'https://open.weixin.qq.com/connect/qrconnect#wechat_redirect',
                                  token_url:     '/sns/oauth2/access_token',
                                  token_method: :get)
      OAuth2::AccessToken.new(client, access_token)
    end
  end
end
