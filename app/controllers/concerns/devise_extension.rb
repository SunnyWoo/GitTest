module DeviseExtension
  extend ActiveSupport::Concern

  def current_user
    user = find_current_user_from_cookie || super
    write_access_token_to_cookie(user) if user.present? && cookies[:access_token].nil?
    user
  end

  # For mobile view checkout
  def write_access_token_to_cookie(user)
    return unless user.present?
    cookies[:access_token] = {
      value: user.access_token,
      expires: 1.month.from_now,
      domain: cookies_domain
    }
  end

  private

  def find_current_user_from_cookie
    if cookies[:access_token].present?
      user = ResourceOwner.from_access_token(cookies[:access_token]).try(:user)
      if user.present?
        sign_in user
        user
      else
        cookies[:access_token] = nil
      end
    end
  end

  def clean_cookies_access_token
    cookies.delete(:access_token, domain: cookies_domain)
  end

  def cookies_domain
    if Rails.env.development?
      'commandp.dev'
    else
      Region.china? ? '.commandp.com.cn' : '.commandp.com'
    end
  end
end
