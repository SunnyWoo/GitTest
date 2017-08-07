class PreviewBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :order_images

  def perform(work_gid, composer_id, uploader, high_quality)
    work = GlobalID::Locator.locate(work_gid)
    composer = PreviewComposer.find(composer_id)

    preview = work.previews.find_by(key: composer.key)
    return if preview.try(:high_quality) && !high_quality

    work.logcraft_source = { channel: 'worker' }
    work.create_activity("begin_build_preview_with_#{uploader}", composer_id: composer.id)

    image_uploader = (work.product_enable_composite_with_horizontal_rotation && (uploader == 'print_image')) ? work.previews.find_by(key: Preview::ORIGINAL_PRINT_IMAGE_KEY).try(:image) : work.send(uploader)

    image = composer.build_order_image(image_uploader)

    scope = work.previews.where(key: composer.key)
    scope.offset(1).destroy_all
    preview = scope.first_or_initialize
    preview.update(image: image,
                   high_quality: high_quality,
                   position: composer.position)

    if work.product_template_exist? && composer.key == 'order-image'
      BuildShareImageWorker.perform_async(work_gid)
    end

    work.create_activity("end_build_preview_with_#{uploader}", composer_id: composer.id, preview_id: preview.id)
  end
end
