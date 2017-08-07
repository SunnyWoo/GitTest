class Webapi::PreviewsSerializer < ActiveModel::Serializer
  attributes :url, :previews

  def url
    object.cover_image.url
  end

  def previews
    object.product.preview_composers.available.where.not(key: Preview::STORE_PREVIEW_KEYS).inject([]) do |array, composer|
      array << { key: composer.key,
                 path: work_preview_image_path(object, composer.key, locale: I18n.locale) }
      array
    end
  end
end
