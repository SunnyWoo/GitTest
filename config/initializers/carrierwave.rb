CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

if Region.china?
  CarrierWave.configure do |config|
    config.storage    = :qiniu
    config.qiniu_access_key     = Settings.Qiniu.access_key_id
    config.qiniu_secret_key     = Settings.Qiniu.secret_access_key
    config.qiniu_bucket         = Settings.Qiniu.bucket
    config.qiniu_bucket_domain  = URI.parse(Settings.Qiniu.cdn_host).host
    config.qiniu_bucket_private = true #default is false
    config.qiniu_block_size     = 4 * 1024 * 1024
    config.qiniu_protocol       = 'https'
    # TODO: uploads/layer/image/<layer_id>/upload.png 如果更新圖層，七牛無法覆蓋圖片
    config.qiniu_can_overwrite = true
  end
else
  CarrierWave.configure do |config|
    config.aws_credentials = {
      access_key_id:     Settings.AWS.s3.access_key_id,
      secret_access_key: Settings.AWS.s3.secret_access_key,
      region:            'ap-northeast-1'
    }
    config.storage    = :aws
    config.aws_bucket = Settings.AWS.s3.bucket
    config.aws_acl    = :public_read
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
    config.asset_host = ActionController::Base.asset_host
    config.remove_previously_stored_files_after_update = false
  end
end

CARRIERWAVE_STORAGE = if Rails.env.development? || Rails.env.test?
                        :file
                      elsif Region.china?
                        :qiniu
                      else
                        :aws
                      end

module CarrierWave
  module MiniMagick

    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient
        img = yield(img) if block_given?
        img
      end
    end

  end

  module Reloader
    def reload(*)
      @_mounters = {}
      super
    end
  end

  ::ActiveRecord::Base.send(:include, Reloader)
end

CarrierWave::Storage::Qiniu::File.prepend Extensions::CarrierWave::Storage::File
CarrierWave::Storage::Qiniu::Connection.prepend Extensions::CarrierWave::Storage::Connection
CarrierWave::Meta.ghostscript_enabled = true
