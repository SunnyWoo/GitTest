# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

class ResourceOwner
  # Get resource owner from assertion grant flow
  # provider: provider name
  # token: access token
  # secret: secret token (only need for oauth1)
  def self.from_assertion(provider, token, secret = nil, user_id)
    return create_guest if provider == 'guest'
    data = send("get_profile_from_#{provider}", token, secret)
    from_omniauth(data, user_id)
  end

  def self.from_omniauth(data, user_id)
    auth = Omniauth.find_or_initialize_by(provider: data.provider, uid: data.uid)
    auth.update!(oauth_token: data.credentials.token, oauth_secret: data.credentials.secret)
    unless auth.owner_id?
      if Region.china?
        fail UnboundError if user_id.nil?
        auth.bind_owner(data, user_id)
      elsif data.provider.in? Omniauth::GLOBAL_PROVIDERS
        if user_id.present?
          auth.bind_owner(data, user_id)
          auth.owner.skip_confirmation!
        else
          auth.create_owner(data)
        end
      else
        fail OauthProviderMissingError, caused_by: data.provider
      end
    end
    fail EmailUnconfirmedError unless auth.owner.confirmed?
    ResourceOwner.new(auth.owner.id)
  end

  def self.from_access_token(access_token)
    doorkeeper_token = Doorkeeper::AccessToken.find_by(token: access_token)
    ResourceOwner.new(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def user
    @user ||= User.find(@id)
  end

  class << self
    private

    def create_guest
      ResourceOwner.new(User.new_guest.id)
    end

    def get_profile_from_facebook(access_token, _ = nil)
      client = OAuth2::Client.new(Settings.Facebook_app_id,
                                  Settings.Facebook_secret,
                                  site: 'https://graph.facebook.com',
                                  authorize_url: 'https://www.facebook.com/dialog/oauth',
                                  token_url: 'oauth/access_token')
      access_token = OAuth2::AccessToken.new(client, access_token)
      raw_info = validate_response(access_token.get('me').parsed)
      generate_facebook_profile(access_token, raw_info)
    end

    def generate_facebook_profile(access_token, raw_info)
      # format stolen from omniauth-facebook
      Hashie::Mash.new(
        'provider' => 'facebook',
        'uid' => raw_info['id'],
        'info' => {
          'nickname' => raw_info['username'],
          'email' => raw_info['email'],
          'name' => raw_info['name'],
          'first_name' => raw_info['first_name'],
          'last_name' => raw_info['last_name'],
          'image' => "https://graph.facebook.com/#{raw_info['id']}/picture?type=large",
          'description' => raw_info['bio'],
          'urls' => {
            'Facebook' => raw_info['link'],
            'Website' => raw_info['website']
          },
          'location' => (raw_info['location'] || {})['name'],
          'verified' => raw_info['verified']
        },
        'credentials' => {
          'token' => access_token.token
        }
      )
    end

    def get_profile_from_twitter(access_token, secret)
      consumer = OAuth::Consumer.new(Settings.twitter.api_key,
                                     Settings.twitter.secret,
                                     authorize_path: '/oauth/authenticate',
                                     site: 'https://api.twitter.com')
      access_token = OAuth::AccessToken.new(consumer, access_token, secret)
      response = access_token.get('/1.1/account/verify_credentials.json?include_entities=false&skip_status=true')
      response.value # it raises error if not 2xx
      raw_info = JSON.parse(response.body)
      generate_twitter_profile(access_token, raw_info)
    end

    def generate_twitter_profile(access_token, raw_info)
      # format stolen from omniauth-twitter
      Hashie::Mash.new(
        'provider' => 'twitter',
        'uid' => raw_info['id_str'],
        'info' => {
          'nickname' => raw_info['screen_name'],
          'name' => raw_info['name'],
          'location' => raw_info['location'],
          'image' => raw_info['profile_image_url'],
          'description' => raw_info['description'],
          'urls' => {
            'Website' => raw_info['url'],
            'Twitter' => "https://twitter.com/#{raw_info['screen_name']}"
          }
        },
        'credentials' => {
          'token' => access_token.token,
          'secret' => access_token.secret
        }
      )
    end

    def get_profile_from_google_oauth2(access_token, _ = nil)
      client = OAuth2::Client.new(Settings.google.app_id,
                                  Settings.google.secret,
                                  site:          'https://accounts.google.com',
                                  authorize_url: '/o/oauth2/auth',
                                  token_url:     '/o/oauth2/token')
      access_token = OAuth2::AccessToken.new(client, access_token, scope: 'email,profile')
      raw_info = validate_response(access_token.get('https://www.googleapis.com/plus/v1/people/me/openIdConnect').parsed)
      generate_google_oauth2_profile(access_token, raw_info)
    end

    def generate_google_oauth2_profile(access_token, raw_info)
      # format stolen from omniauth-google-oauth2
      Hashie::Mash.new(
        'provider' => 'google_oauth2',
        'uid' => raw_info['sub'],
        'info' => {
          'name' => raw_info['name'],
          'email' => raw_info['email'],
          'first_name' => raw_info['given_name'],
          'last_name' => raw_info['family_name'],
          'image' => raw_info['picture'],
          'urls' => {
            'Google' => raw_info['profile']
          }
        },
        'credentials' => {
          'token' => access_token.token
        }
      )
    end

    def get_profile_from_qq(access_token, _ = nil)
      access_token = qq_access_token(access_token)
      openid = get_qq_openid(access_token)
      openid_params = { openid: openid, oauth_consumer_key: Settings.qq.app_id, format: :json }
      raw_info = validate_response(access_token.get('/user/get_user_info', params: openid_params, parse: :json).parsed)
      generate_qq_profile(access_token, raw_info, openid)
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

    def generate_qq_profile(access_token, raw_info, openid)
      # format stolen from omniauth-qq-oauth2
      Hashie::Mash.new(
        'provider' => 'qq',
        'uid' => openid,
        'info' => {
          'name' => raw_info['nickname'],
          'image' => raw_info['figureurl_1'],
          'urls' => {
            'Qq' => raw_info['profile']
          }
        },
        'credentials' => {
          'token' => access_token.token
        }
      )
    end

    def get_profile_from_weibo(access_token, _ = nil)
      access_token = weibo_access_token(access_token)
      uid = get_weibo_uid(access_token)
      raw_info = validate_response(access_token.get('/2/users/show.json', params: { uid: uid }).parsed)
      generate_weibo_profile(access_token, raw_info, uid)
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

    def generate_weibo_profile(access_token, raw_info, uid)
      # format stolen from omniauth-weibo-oauth2
      if raw_info['domain'].present?
        weibo_url = "http://weibo.com/#{raw_info['domain']}"
      else
        weibo_url = "http://weibo.com/u/#{raw_info['id']}"
      end
      Hashie::Mash.new(
        'provider' => 'weibo',
        'uid' => uid.to_s,
        'info' => {
          'nickname' => raw_info['screen_name'],
          'name' => raw_info['name'],
          'image' => raw_info[%w(avatar_hd avatar_large profile_image_url).find { |e| raw_info[e].present? }],
          'location' => raw_info['location'],
          'description' => raw_info['description'],
          'urls' => {
            'Blog' => raw_info['url'],
            'Weibo' => weibo_url
          }
        },
        'credentials' => {
          'token' => access_token.token
        }
      )
    end

    def get_profile_from_wechat(access_token, openid)
      access_token = wechat_access_token(access_token)
      access_token.options[:mode] = :query
      raw_info = JSON access_token.get('/sns/userinfo', params: { openid: openid }).parsed
      generate_wechat_profile(access_token, raw_info)
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

    def generate_wechat_profile(access_token, raw_info)
      # wechat的Omniauth#uid使用unionid(区分多个wecaht应用用户的唯一性)
      Hashie::Mash.new(
        'provider' => 'wechat',
        'uid' => raw_info['unionid'],
        'info' => {
          'name' => raw_info['nickname'],
          'image' => raw_info['headimgurl']
        },
        'credentials' => {
          'token' => access_token.token
        }
      )
    end

    def validate_response(response)
      error_message = response['error'] || response['errors']
      fail error_message if error_message
      response
    end
  end
end
