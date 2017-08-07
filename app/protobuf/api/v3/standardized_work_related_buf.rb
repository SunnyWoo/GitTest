class Api::V3::StandardizedWorkRelatedBuf
  def initialize(standardized_work, params)
    @standardized_work = standardized_work
    @params = params
  end

  def to_pb
    swpb = Proto::StandardizedWorkRelatedPb.new
    swpb.related_works = related_works
    swpb.meta = meta
    swpb.encode
  end

  def related_works
    rw = Proto::RelatedWorkPb.new
    rw.series_works = series_works
    rw.designer_works = designer_works
    rw.recommend_works = recommend_works
    rw
  end

  def recommend_works
    @standardized_work.recommend_works(@params[:recommend_count]).map do |work|
      work_buf(work)
    end
  end

  def series_works
    @standardized_work.series_works(@params[:series_count]).map do |work|
      work_buf(work)
    end
  end

  def designer_works
    @standardized_work.designer_works(@params[:designer_count]).map do |work|
      work_buf(work)
    end
  end

  def meta
    Proto::MetaPb.new(
        series_count: @standardized_work.series_works(@params[:series_count]).count,
        designer_count: @standardized_work.designer_works(@params[:designer_count]).count,
        recommend_count: @standardized_work.recommend_works(@params[:recommend_count]).count
    )
  end

  def work_buf(work)
    order_image = Monads::Optional.new(work.order_image)
    previews = work.respond_to?(:ordered_previews) ? work.ordered_previews : work.previews
    Proto::WorkPb.new(
        id: work.id,
        gid: work.to_gid_param,
        uuid: work.uuid,
        name: work.name,
        user_id: work.user_id,
        user_avatar: Proto::UserAvatarPb.new(work.user_avatar.as_json),
        order_image: Proto::OrderImagePb.new(
            thumb: order_image.thumb.url.value,
            share: order_image.share.url.value,
            sample: order_image.sample.url.value,
            normal: order_image.url.value
        ),
        gallery_images: previews.map do |preview|
          Proto::PreviewPb.new(
              id: preview.id,
              normal: preview.image.url,
              thumb: preview.image.thumb.url,
              key: preview.key,
              url: preview.image.url,
              image_url: preview.image.url,
              position: preview.position
          )
        end,

        prices: Proto::PricePb.new(work.prices),
        original_prices: Proto::PricePb.new(work.original_prices),
        user_display_name: work.user_display_name,
        wishlist_included: false,
        slug: work.slug,
        is_public: work.is_public?,
        user_avatars: Proto::UserAvatarPb.new(s35: work.user.avatar.s35.url, s154: work.user.avatar.s154.url),
        product: Proto::ProductModelPb.new(
            id: work.product.id,
            key: work.product.key,
            name: work.product.name,
            description: work.product.description,
            prices: Proto::PricePb.new(work.product.prices),
            customized_special_prices: Proto::PricePb.new(work.product.customized_special_prices),
            design_platform: work.product.design_platform,
            customize_platform: work.product.customize_platform,
            placeholder_image: work.product.placeholder_image.url,
            width: work.product.width,
            height: work.product.height,
            dpi: work.product.dpi,
            background_image: work.product.background_image.url,
            overlay_image: work.product.overlay_image.url,
            padding_top: work.product.padding_top,
            padding_right: work.product.padding_right,
            padding_bottom: work.product.padding_bottom,
            padding_left: work.product.padding_left
        ),
        category: Proto::ProductCategoryPb.new(work.category.slice(:id, :key, :name)),
        tags: work.tags.map { |tag| Proto::TagPb.new(tag.slice(:id, :name, :text)) }
    )
  end
end
