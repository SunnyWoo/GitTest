# == Schema Information
#
# Table name: works
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cover_image             :string(255)
#  work_type               :integer          default(1)
#  finished                :boolean          default(FALSE)
#  feature                 :boolean          default(FALSE)
#  uuid                    :string(255)
#  print_image             :string(255)
#  model_id                :integer
#  artwork_id              :integer
#  image_meta              :json
#  slug                    :string(255)
#  impressions_count       :integer          default(0)
#  ai                      :string(255)
#  pdf                     :string(255)
#  price_tier_id           :integer
#  attached_cover_image_id :integer
#  template_id             :integer
#  deleted_at              :datetime
#  user_type               :string(255)
#  user_id                 :integer
#  application_id          :integer
#  product_template_id     :integer
#  cradle                  :integer          default(0)
#  share_text              :text
#  variant_id              :integer
#

# NOTE: not used in v3 api, remove me later
class WorkSerializer < ActiveModel::Serializer
  include WorkroundOriginalPrices
  attributes :uuid, :finished, :cover_image, :name, :model, :product, :category,
             :editable, :feature, :category, :prices, :original_prices, :preview_images
  has_one :user, serializer: UserSerializer

  def cover_image
    {
      'thumb' => object.cover_image.thumb.url,
      'normal' => object.cover_image.on_the_fly_process(resize_to_limit: [nil, 750]).url,
      'shop' => object.order_image.url
    }
  end

  def preview_images
    object.previews.map(&:image_url)
  end

  def editable
    object.layers.length > 1
  end

  def product
    object.product.name
  end

  alias_method :model, :product

  def category
    {
      id: object.category.id,
      key: object.category.key,
      name: object.category.name,
      model: {
        id: object.product.id,
        key: object.product.key,
        name: object.product.name
      },
      product: {
        id: object.product.id,
        key: object.product.key,
        name: object.product.name
      }
    }
  end
end
