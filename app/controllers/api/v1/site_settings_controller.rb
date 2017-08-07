class Api::V1::SiteSettingsController < ApiController
  # Site Settings
  #
  # Url : /api/app_version
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/app_version
  #
  # Return Example
  #  {
  #    "iOS":"1.0.2",
  #    "Android":"1.0.0"
  #  }
  #
  # @return [JSON] status 200

  def app_version
    render json: {
      iOS: SiteSetting.by_key('iOSVersion'),
      Android: SiteSetting.by_key('AndroidVersion')
    }
    fresh_when(etag: [SiteSetting.by_key('iOSVersion'), SiteSetting.by_key('AndroidVersion')])
  end
end
