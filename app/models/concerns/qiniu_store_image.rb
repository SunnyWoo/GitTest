module QiniuStoreImage
  extend ActiveSupport::Concern

  def qiniu_cover_image_url
    return nil unless cover_image.try(:url)
    uploader = QiniuUploader.new(self, :cover_image)
    download!(uploader, cover_image.url)
    uploader.store!
    uploader.file.path
  rescue CarrierWave::DownloadError
    nil
  end

  def qiniu_cover_image_shop_url
    return nil unless cover_image.try(:shop).try(:url)
    uploader = QiniuUploader.new(self, :cover_image)
    download!(uploader, cover_image.shop.url)
    uploader.store!
    uploader.file.path
  rescue CarrierWave::DownloadError
    nil
  end

  def qiniu_print_image_url
    return nil unless print_image.try(:url)
    uploader = QiniuUploader.new(self, :print_image)
    download!(uploader, print_image.url)
    uploader.store!
    uploader.file.path
  rescue CarrierWave::DownloadError
    nil
  end

  def qiniu_order_image_url
    return nil unless order_image.try(:url)
    uploader = QiniuUploader.new(self, :order_image)
    download!(uploader, order_image.url)
    uploader.store!
    uploader.file.path
  rescue CarrierWave::DownloadError
    nil
  end

  private

  def download!(uploader, image_url)
    uploader.download!(image_url)
  end
end
