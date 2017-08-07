# encoding: utf-8

class RawUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include Sprockets::Rails::Helper

  storage CARRIERWAVE_STORAGE

  process :set_content_type
  # process :strip
  # process quality: 100

  # Public: Assets 預設的儲存目錄路徑
  #
  # Returns String
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def url(*args)
    super.try do |original_url|
      updated_at = model.updated_at || Time.zone.now
      "#{original_url.split('?v=').first}?v=#{updated_at.to_i}"
    end
  end
end
