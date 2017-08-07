class Oauth2UserService
  attr_accessor :auth, :user, :omniauth

  def initialize(auth, omniauth, email)
    @auth = auth
    @omniauth = omniauth
    email = email || auth['email'] || "guest_#{Time.now.to_i}#{rand(99)}@commandp.com"
    @user = find_or_create_user(email)
  end

  def execute
    p = case @omniauth.provider
        when 'facebook'
          from_facebook
        when 'twitter'
          from_twitter
        when 'google_oauth2'
          from_google_oauth2
        when 'qq'
          from_qq
        when 'weibo'
          from_weibo
        when 'wechat'
          from_wechat
        end
    update_user(p)
  end

  protected

  def find_or_create_user(email)
    user = User.where(email: email).first_or_initialize
    if user.new_record?
      user.password = Devise.friendly_token
      user.locale = I18n.locale
      user.skip_confirmation!
      user.save
    end
    user
  end

  def update_user(proc)
    proc.call(auth, user)
    omniauth.email = user.email
    omniauth.username = user.name
    omniauth.owner = user
    omniauth.save!
    return omniauth.owner
  end

  def from_facebook
    Proc.new do |auth, user|
      user.remote_avatar_url ||= "https://graph.facebook.com/#{auth["id"]}/picture?width=999&height=999"
      user.name ||= auth['name']
      user.gender ||= auth['gender']
      user.first_name ||= auth['first_name']
      user.last_name ||= auth['last_name']
      user.birthday ||= auth['birthday'].try(:to_date).to_s
    end
  end

  def from_twitter
    Proc.new do |auth, user|
      user.remote_avatar_url ||= auth['profile_image_url']
      user.location ||= auth['profile_location']
      user.name ||= auth['name']
    end
  end

  def from_google_oauth2
    Proc.new do |auth, user|
      user.remote_avatar_url ||= auth['picture']
      user.gender ||= auth['gender']
      user.name ||= auth['name']
      user.first_name ||= auth['first_name'] || auth['family_name']
      user.last_name ||= auth['last_name'] || auth['given_name']
    end
  end

  def from_qq
    proc do |auth, user|
      user.remote_avatar_url ||= auth['figureurl_1']
      user.name ||= auth['nickname']
    end
  end

  def from_weibo
    proc do |auth, user|
      user.remote_avatar_url ||= auth[%w(avatar_hd avatar_large profile_image_url).find { |e| auth[e].present? }]
      user.location ||= auth['location']
      user.name ||= auth['name']
    end
  end

  def from_wechat
    proc do |auth, user|
      user.remote_avatar_url ||= auth['headimgurl']
      user.name ||= auth['nickname']
    end
  end
end
