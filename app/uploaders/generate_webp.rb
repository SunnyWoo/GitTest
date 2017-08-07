module GenerateWebp
  extend ActiveSupport::Concern
  include OnTheFlyRecreateVersions

  def enable_web?(*)
    image? && !model.is_a?(Attachment) && !Rails.env.test?
  end

  included do
    version :webp, if: :enable_web? do
      process :convert_to_webp

      # overwrite for generate file with "#{original_filename}.webp" filename
      # not "#{version_name}_#{original_filename}.webp"
      def full_filename(for_file)
        return nil if for_file.nil?
        for_file.chomp(File.extname(for_file)) + '.webp'
      end

      # overwrite for old image getting a webp url when file not exist
      def url(*args)
        return nil if file.nil?
        if file.exists?
          super.try do |original_url|
            updated_at = model.updated_at || Time.zone.now
            "#{original_url.split('?v=').first}?v=#{updated_at.to_i}"
          end
        else
          on_the_fly_recreate_version!('webp', lazy: true).url
        end
      end

      def convert_to_webp(options = {})
        manipulate! do |img|
          webp_path = img.path.gsub(File.extname(img.path), '.webp')
          # with_store = options.delete(:with_store)

          ::WebP.encode(img.path, webp_path, options)

          # if with_store
          #   storage.store! CarrierWave::SanitizedFile.new({
          #                                                     tempfile: webp_path, filename: webp_path,
          #                                                     content_type: 'image/webp'
          #                                                 })
          # end
          MiniMagick::Image.new(webp_path)
        end
      end
    end
  end
end
