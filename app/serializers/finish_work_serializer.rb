# NOTE: not used in v3 api, remove me later
class FinishWorkSerializer < ActiveModel::Serializer
  include WorkroundOriginalPrices
  attributes :uuid, :name, :description, :model, :product, :cover_image,
             :policy, :finished, :prices, :preview_images, :original_prices
  has_many :layers
  has_one :user

  def policy
    object.is_public? ? 'public' : 'private'
  end

  def cover_image
    {
      'thumb' => object.cover_image.thumb.url,
      'normal' => object.cover_image.url
    }
  end

  def product
    {
      key: object.product.key,
      name: object.product.name
    }
  end
  alias_method :model, :product

  def preview_images
    object.previews.map(&:image_url)
  end
end
