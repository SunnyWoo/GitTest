class PreviewSamplesBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :order_images

  def perform(id, updated_at)
    composer = PreviewComposer.find(id)
    return unless composer.updated_at.to_s == updated_at

    composer.sample_works.each do |work|
      PreviewSampleBuilder.perform_async(composer.id, work.to_gid_param, composer.updated_at.to_s)
    end
  end
end
