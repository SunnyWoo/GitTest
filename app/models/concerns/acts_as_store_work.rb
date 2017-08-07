module ActsAsStoreWork
  extend ActiveSupport::Concern

  def share_preview
    previews.find_by(key: 'share')
  end

  def download_preview
    previews.find_by(key: 'download')
  end

  def build_share_image
    return unless product_template.present?
    scope = previews.where(key: 'share')
    scope.offset(1).destroy_all
    preview = scope.first_or_initialize
    preview.update(image: ImageService::OrderImageWithStoreFooter.new(self).generate)
  end

  module ClassMethods
    def non_store
      commandp
    end
  end
end
