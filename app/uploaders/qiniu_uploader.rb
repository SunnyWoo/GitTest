class QiniuUploader < CarrierWave::Uploader::Base
  if Rails.env.development? || Rails.env.test?
    storage :file
  else
    storage :qiniu

    self.qiniu_can_overwrite = false
    self.qiniu_access_key = Settings.deliver_order.qiniu.access_key_id
    self.qiniu_secret_key = Settings.deliver_order.qiniu.secret_access_key
    self.qiniu_bucket = Settings.deliver_order.qiniu.bucket
    self.qiniu_bucket_domain = Settings.deliver_order.qiniu.bucket_domain
    self.qiniu_bucket_private = true # default is false
    self.qiniu_block_size = 4 * 1024 * 1024
    self.qiniu_protocol = 'http'
    self.qiniu_up_host = 'http://up.qiniug.com'
  end

  def store_dir
    "uploads/delivery/#{model.class.name.underscore}/#{mounted_as}/#{model.id}"
  end

  delegate :download_url, to: :qiniu_connection

  private

  def qiniu_connection
    @qiniu_connection ||= begin
      config = {
        qiniu_access_key: qiniu_access_key,
        qiniu_secret_key: qiniu_secret_key,
        qiniu_bucket: qiniu_bucket,
        qiniu_bucket_domain: qiniu_bucket_domain,
        qiniu_bucket_private: qiniu_bucket_private,
        qiniu_block_size: qiniu_block_size,
        qiniu_protocol: qiniu_protocol,
        qiniu_expires_in: qiniu_expires_in,
        qiniu_up_host: qiniu_up_host,
        qiniu_private_url_expires_in: qiniu_private_url_expires_in,
        qiniu_callback_url: qiniu_callback_url,
        qiniu_callback_body: qiniu_callback_body,
        qiniu_persistent_notify_url: qiniu_persistent_notify_url
      }

      config[:qiniu_async_ops] = begin
                                   Array(qiniu_async_ops).join(';')
                                 rescue
                                   ''
                                 end
      begin
        config[:qiniu_can_overwrite] = try :qiniu_can_overwrite
      rescue
        false
      end

      CarrierWave::Storage::Qiniu::Connection.new config
    end
  end
end
