module PreviewsGenerator
  extend ActiveSupport::Concern

  included do
    attr_accessor :perform_destroy_previews
    has_many :previews, as: :work, dependent: :destroy
    after_update :destroy_previews, if: :perform_destroy_previews
  end

  def cover_image_stored!
    @cover_image_stored = true
  end

  def print_image_stored!
    @print_image_stored = true
  end

  def cover_image_stored?
    @cover_image_stored
  end

  def print_image_stored?
    @print_image_stored
  end

  def enqueue_build_previews_by_cover_image(delay = nil)
    @cover_image_stored = false
    if delay
      PreviewsBuilder.perform_in(delay, to_gid, :cover_image, false)
    else
      PreviewsBuilder.perform_async(to_gid, :cover_image, false)
    end
  end

  def enqueue_build_previews_by_print_image(delay = nil)
    @print_image_stored = false
    if delay
      PreviewsBuilder.perform_in(delay, to_gid, :print_image, true)
    else
      PreviewsBuilder.perform_async(to_gid, :print_image, true)
    end
  end

  def ordered_previews
    previews.where(key: preview_keys)
  end

  def previews_ready?
    preview_keys.size <= ordered_previews.size
  end

  def preview_keys
    product.preview_composers.available.where(template_id: nil).pluck(:key)
  end

  def destroy_previews
    previews.destroy_all
  end

  def disable_build_order_image?
    product.create_order_image_by_cover_image? && self.class.in?([Work, ArchivedWork])
  end
end
