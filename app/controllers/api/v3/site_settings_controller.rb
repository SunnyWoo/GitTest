class Api::V3::SiteSettingsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/app_version the latest app version
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup SiteSetting
@apiName GetAppVersion
@apiSuccessExample {json} Response-Example:
 {
  "iOS": "1.0.2",
  "Android": "1.0.0",
  "RN_iOS": {
    'version' => '1.0.0',
    'minContainerVersion' => '1.0.0',
    'url' => {
      'url' => 'https://commandp.com',
      'isRelative' => false
    }
  },
  "RN_Android": {
    'version' => '1.0.0',
    'minContainerVersion' => '1.0.0',
    'url' => {
      'url' => 'https://commandp.com',
      'isRelative' => false
    }
  }
 }
=end
  def app_version
    render json: {
      iOS: SiteSetting.by_key('iOSVersion'),
      Android: SiteSetting.by_key('AndroidVersion'),
      RN_iOS: SiteSetting.rn_ios_meta,
      RN_Android: SiteSetting.rn_android_meta
    }
    fresh_when(etag: [SiteSetting.by_key('iOSVersion'), SiteSetting.by_key('AndroidVersion'), SiteSetting.rn_ios_meta, SiteSetting.rn_android_meta])
  end
end
