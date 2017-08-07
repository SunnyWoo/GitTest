module CurrentCountryCode
  extend ActiveSupport::Concern

  module ClassMethods
    def geoip
      @geoip ||= GeoIP.new('vendor/geoip_data/GeoIP.dat')
    end
  end

  included do
    helper_method :current_country_code, :come_from_china?
  end

  #
  # 從IP 取得使用者的 Country Code
  #
  # @return String CountryCode Ex: US
  def current_country_code
    @current_country_code ||= country_code_by_ip(client_ip)
  end

  def client_ip
    request.headers['X-Forwarded-For'] && request.headers['X-Forwarded-For'].split(',').first || remote_ip
  end

  def country_code_by_ip(ip, default_country_code: 'US')
    country_code = geoip.country(ip).country_code2
    (country_code != '--') ? country_code : default_country_code
  end

  def geoip
    self.class.geoip
  end

  def come_from_china?
    current_country_code == 'CN'
  end

  def ban_if_come_from_china
    return if with_code_shanghai?
    render 'errors/not_available_in_china', status: 426 if come_from_china?
  end

  def with_code_shanghai?
    params[:CODE] == 'shanghai'
  end

  def non_redirect_china_site?
    return true if request.path.in?(not_redirect_china_paths)
    if with_code_shanghai?
      cookies[:non_redirect_china_site] = params[:CODE]
      return true
    else
      return true if cookies[:non_redirect_china_site] == 'shanghai'
    end
    false
  end

  # 顺丰的推送不跳转到china站
  def not_redirect_china_paths
    %w(/webhook/sf_express/route)
  end
end
