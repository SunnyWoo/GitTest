# encoding: utf-8

class DefaultUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # include CarrierWave::GraphicsMagick
  include CarrierWave::MimeTypes
  include CarrierWave::Processing::MiniMagick
  include Sprockets::Rails::Helper
  include CarrierWave::Meta
  include CarrierWave::ImageOptimizer
  include OnTheFlyProcessor
  include PreprocessImage::CarrierWaveCallbacks
  # include GenerateWebp

  storage CARRIERWAVE_STORAGE

  process :set_content_type
  # 優化 uploader 上傳速度
  # 改成 layer background execute, 猜測 只有 layer 的圖片需要 auto_orient
  # process :auto_orient
  # slide_uploader 單獨執行
  # process :interlace

  # process :strip
  # process quality: 100

  def self.optimize!
    process :optimize if Settings.optimize
  end

  # modify form https://github.com/carrierwaveuploader/carrierwave/blob/master/lib/carrierwave/uploader/processing.rb#L54-L64
  def self.prepend_process(*args)
    new_processors = args.inject({}) do |hash, arg|
      arg = { arg => [] } unless arg.is_a?(Hash)
      hash.merge!(arg)
    end

    condition = new_processors.delete(:if)
    new_processors.each do |processor, processor_args|
      self.processors = [[processor, processor_args, condition]] + processors
    end
  end

  # Public: Assets 預設的儲存目錄路徑
  #
  # Returns String
  def store_dir
    class_name = if model.class.respond_to?(:actual_class_name)
                   model.class.actual_class_name.underscore
                 else
                   model.class.name.underscore
                 end
    "uploads/#{class_name}/#{mounted_as}/#{model.id}"
  end

  def auto_orient
    return if !image? || svg?
    manipulate! do |img|
      img.auto_orient
      img.strip
      img
    end
  end

  def interlace
    return if !image? || svg?
    manipulate! do |img|
      img.combine_options do |c|
        c.interlace 'plane'
      end
      img
    end
  end

  def colorspace(profile)
    manipulate! do |img|
      img.format('jpg') do |f|
        f.colorspace(profile)
      end
      img
    end
  end

  def data_uri
    mime_type = file.content_type
    encoded_data = Base64.encode64(file.read)
    "data:#{mime_type};base64,#{encoded_data}"
  end

  def mime_type
    file.content_type
  end

  def image?(*)
    mime_type =~ /^image/
  end

  def svg?
    mime_type == 'image/svg+xml'
  end

  def url(*args)
    super.try do |original_url|
      updated_at = model.updated_at || Time.zone.now
      "#{original_url.split('?v=').first}?v=#{updated_at.to_i}"
    end
  end

  case CARRIERWAVE_STORAGE
  when :file, :aws
    def escaped_url(*args)
      generated_url = url(*args)
      URI.escape(generated_url) if generated_url
    end
  when :qiniu
    def escaped_url(*args)
      url(*args)
    end
  end

  def filename
    if original_filename.present?
      if model && model.read_attribute(mounted_as).present? && !model.changed.include?(mounted_as.to_s)
        model.read_attribute(mounted_as)
      else
        "#{secure_token}.#{file.extension}"
      end
    end
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
