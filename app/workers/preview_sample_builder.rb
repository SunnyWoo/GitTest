class PreviewSampleBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :order_images

  def perform(composer_id, work_gid, updated_at)
    composer = PreviewComposer.find(composer_id)
    return unless composer.updated_at.to_s == updated_at
    work = GlobalID.find(work_gid)

    image = composer.build_order_image(work.print_image)
    composer.samples.create(result: image)
  end
end
