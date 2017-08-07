class ImageProcessor
  include Sidekiq::Worker
  sidekiq_options queue: :process_images

  def perform(model_class, id, uploader, version)
    model = model_class.constantize.find(id)
    image_url = model.send(uploader).send(version).url
    HTTParty.get(image_url) if image_url
  rescue ActiveRecord::RecordNotFound => e
    # 找不到 model 就不用做縮圖啦!
    Rails.logger.warn "Error in ImageProcessor: #{e.message}"
  end

  def self.perform_version(uploader, version)
    perform_async(uploader.model.class.name,
                  uploader.model.id,
                  uploader.mounted_as,
                  version)
  end
end
