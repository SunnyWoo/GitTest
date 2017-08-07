# modified from https://gist.github.com/DAddYE/1541912
module OnTheFlyRecreateVersions
  def on_the_fly_recreate_version!(version_name, option = {})
    lazy = option.fetch(:lazy, true)
    if lazy
      uploader_class = Class.new(self.class)
      uploader = uploader_class.new(model, mounted_as)
      uploader.extend(URLGenerator)
      uploader.version_name = version_name
      uploader
    else
      model.send(mounted_as).recreate_versions!(version_name.to_sym)
      model.send(mounted_as).send(version_name.to_sym)
    end
  end

  module URLGenerator
    attr_accessor :version_name

    def url(*)
      id = generate_medium_id
      host = Settings.action_controller.asset_host
      format = if version_name.to_s == 'webp'
                 'webp'
               else
                 File.extname(model.read_attribute(mounted_as))[1..-1] # remove prefix dot
               end
      Rails.application.routes.url_helpers.recreate_versions_medium_url(id: id, host: host, format: format)
    end

    def generate_medium_id
      job = [model.to_gid.to_s, mounted_as, version_name, model.try(:updated_at).to_i]
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
