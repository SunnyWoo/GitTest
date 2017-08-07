class PreviewsBuilder
  include Sidekiq::Worker

  def perform(work_gid, uploader, high_quality)
    work = GlobalID::Locator.locate(work_gid)

    # 非b2b2c的work的preview_composer不會有template_id
    preview_composers = work.product.preview_composers.where(template_id: nil).available
    available_keys = preview_composers.pluck(:key)

    work.previews.where('key not in (?)', available_keys + Preview::PRESERVING_PREVIEW_KEYS).destroy_all
    # 我本來不想用這招的, 但是應pm要求,某些product_model不會有設定preview_composer,此時會直接以cover_image當做order_image;而standardized_work則是由相關人員自行上傳
    if work.disable_build_order_image?
      work.previews.create image: work.cover_image, position: 1, key: 'order-image'
    else
      preview_composers.each do |composer|
        PreviewBuilder.perform_async(work_gid, composer.id, uploader, high_quality)
      end
    end
  end
end
