# encoding: utf-8

class PdfUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include Sprockets::Rails::Helper

  storage CARRIERWAVE_STORAGE

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(pdf)
  end

  def pdf?
    case CARRIERWAVE_STORAGE
    when :file
      MIME::Types.type_for(file.file).first.content_type == 'application/pdf'
    else
      file.content_type == 'application/pdf'
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
end
