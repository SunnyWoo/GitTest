# modified from https://gist.github.com/DAddYE/1541912
module OnTheFlyProcessor
  def resize(size)
    dimension = size.split('x').map(&:to_i)
    resizer = case size
              when /[!#]/ then :resize_to_fit
              else             :resize_to_fill
              end
    on_the_fly_process(resizer => dimension)
  end

  def on_the_fly_process(processors)
    return self if blank?

    uploader_class = Class.new(self.class)
    uploader = uploader_class.new(model, mounted_as)
    uploader.extend(URLGenerator)
    uploader.processors = processors

    uploader
  end

  def do_processing(processors)
    return extend(MediaPath) if blank?

    uploader_class = Class.new(self.class)
    uploader = uploader_class.new(model, mounted_as)

    uploader.retrieve_from_store!(identifier)
    uploader.cache!(file)
    uploader.send(:original_filename=, original_filename)

    processors.each { |key, value| uploader.send(key, *value) }

    uploader.extend(MediaPath)
    uploader.fly_processed = true
    uploader
  rescue CarrierWave::ProcessingError
    extend(MediaPath)
  end

  module MediaPath
    attr_accessor :fly_processed

    def fly_processed_path
      return path if fly_processed || CARRIERWAVE_STORAGE == :file
      url
    end
  end

  module URLGenerator
    attr_accessor :processors

    def url(*)
      id = generate_medium_id
      host = Settings.action_controller.asset_host
      format = File.extname(model.read_attribute(mounted_as))[1..-1] # remove prefix dot
      Rails.application.routes.url_helpers.medium_url(id: id, host: host, format: format)
    end

    def generate_medium_id
      job = [model.to_gid.to_s, mounted_as, processors, model.try(:updated_at).to_i]
      verifier.generate(job)
    end

    def verifier
      URLGenerator.verifier
    end

    def self.verifier
      @verifier ||= Rails.application.message_verifier('on_the_fly_process')
    end
  end
end
