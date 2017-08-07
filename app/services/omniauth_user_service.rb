class OmniauthUserService
  attr_accessor :auth, :user, :omniauth

  def initialize(auth, user, omniauth)
    @auth = auth
    @user = user
    @omniauth = omniauth
  end

  def execute
    p = case auth.provider
        when 'facebook'
          create_by_facebook
        when 'twitter'
          create_by_twitter
        when 'weibo'
          create_by_weibo
        when 'google_oauth2'
          create_by_google_oauth2
        when 'qq'
          create_by_qq
        end
    update_omniauth_and_user(p)
  end

  def update_omniauth_and_user(proc)
    user.name ||= auth.info.name
    proc.call(auth, user, omniauth)
    user.locale = I18n.locale
    user.save!
    omniauth.owner = user
    omniauth.email = user.email
    omniauth.username = auth.info.name
    omniauth.save!
  end

  def create_by_facebook
    Proc.new do |auth, user, omniauth|
      user.remote_avatar_url = "https://graph.facebook.com/#{auth.uid}/picture?width=999&height=999"
      user.location ||= auth.info.location
      user.gender ||= auth.extra.raw_info.gender
      user.first_name ||= auth.extra.raw_info.first_name
      user.last_name ||= auth.extra.raw_info.last_name
      user.birthday ||= auth.extra.raw_info.birthday.try(:to_date).to_s
      omniauth.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def create_by_twitter
    Proc.new do |auth, user, omniauth|
      user.remote_avatar_url ||= auth.info.image
      user.location ||= auth.info.location
    end
  end

  def create_by_weibo
    Proc.new do |auth, user, omniauth|
      user.remote_avatar_url ||= auth.info.image
      user.location ||= auth.info.location
      omniauth.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def create_by_google_oauth2
    Proc.new do |auth, user, omniauth|
      user.remote_avatar_url ||= auth.info.image
      raw_info = auth.extra.raw_info
      user.gender ||= raw_info.gender
      user.first_name = raw_info.first_name || raw_info.family_name
      user.last_name = raw_info.last_name || raw_info.given_name
      omniauth.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def create_by_qq
    proc do |auth, user, omniauth|
      user.remote_avatar_url ||= auth.info.image
      omniauth.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
  end
end
