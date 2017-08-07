# Preprocess version images in background.
#
# == Usage
#
#     include PreprocessImage
#     preprocess_image :cover_image, versions: %w(thumb shop)
#
# `thumb` and `shop` version will be process in background when `cover_image` was changed
module PreprocessImage
  extend ActiveSupport::Concern

  module ClassMethods
    def preprocess_image(mounted_as, versions: nil)
      preprocess_images[mounted_as] = Array(versions)
    end

    def preprocess_images
      @preprocess_images ||= {}
    end
  end

  module CarrierWaveCallbacks
    extend ActiveSupport::Concern

    included do
      after :store, :enqueue_process_images
    end

    def enqueue_process_images(_file)
      return unless model.class.is_a?(PreprocessImage)
      versions = model.class.preprocess_images[mounted_as]
      versions.each do |version|
        ImageProcessor.perform_version(self, version)
      end
    end
  end
end
