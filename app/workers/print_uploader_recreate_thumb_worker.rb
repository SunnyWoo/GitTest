class PrintUploaderRecreateThumbWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform(gid, mounted_as)
    model = GlobalID::Locator.locate(gid)
    mounted = model.send(mounted_as)
    return unless mounted.present? && mounted.is_a?(PrintUploader)
    begin
      mounted.recreate_versions!(:thumb)
      model.touch
    rescue
      nil
    end
  end
end
