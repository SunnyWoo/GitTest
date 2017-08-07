class MediaController < ApplicationController
  skip_before_action :set_locale

  def show
    expires_in 1.year, public: true
    return unless stale?(etag: params[:id])
    gid, mounted_as, processors = verifier.verify(params[:id])
    Rails.logger.debug "Processing #{gid} #{mounted_as} with #{processors.to_json}..."
    model = GlobalID::Locator.locate(gid)
    fail ActiveRecord::RecordNotFound, 'Avoid application/pdf' if model.send(mounted_as).file.content_type == 'application/pdf'
    uploader = model.send(mounted_as).do_processing(processors)
    send_data open(uploader.fly_processed_path).read, type: uploader.content_type, disposition: 'inline'
    File.delete(uploader.fly_processed_path) if uploader.fly_processed
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    fail ActiveRecord::RecordNotFound, e.message
  end

  def recreate_versions
    expires_in 1.year, public: true
    return unless stale?(etag: params[:id])
    gid, mounted_as, version_name = verifier.verify(params[:id])
    Rails.logger.debug "Processing #{gid} #{mounted_as} with #{version_name}..."
    model = GlobalID::Locator.locate(gid)
    fail ActiveRecord::RecordNotFound, 'Avoid application/pdf' if model.send(mounted_as).file.content_type == 'application/pdf'
    model.send(mounted_as).recreate_versions!(version_name.to_sym)
    version_image = model.send(mounted_as).send(version_name.to_sym)
    # 因为本地环境一般是 'WEBrick' 一次只能处理一个请求
    if Rails.env.development? && CARRIERWAVE_STORAGE == :file
      send_data open(version_image.path).read, type: version_image.file.content_type, disposition: 'inline'
    else
      send_data open(version_image.url).read, type: version_image.file.content_type, disposition: 'inline'
    end
  end

  private

  def verifier
    self.class.verifier
  end

  def self.verifier
    @verifier ||= Rails.application.message_verifier('on_the_fly_process')
  end
end
