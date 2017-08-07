# encoding: utf-8
module CarrierWave
  module GraphicsMagick
    extend ActiveSupport::Concern

    included do
      begin
        require "graphicsmagick"
      rescue LoadError => e
        e.message << " (You may need to install the graphicsmagick gem)"
        raise e
      end
    end

    def gm_manipulate!
      cache_stored_file! if !cached?
      image = ::GraphicsMagick::Image.new(current_path)
      image = yield(image)
      image.write!
      image
    rescue => e
      raise CarrierWave::ProcessingError.new("Failed to manipulate file! #{e}")
    end
  end
end
