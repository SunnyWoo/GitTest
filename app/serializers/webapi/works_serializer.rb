class Webapi::WorksSerializer < ActiveModel::Serializer
  attributes :id, :uuid, :name, :order_image, :username, :price

  def order_image
    {
      'thumb' => object.order_image.thumb.url,
      'normal' => object.order_image.url
    }
  end

  def username
    object.user_display_name
  end

  def price
    object.product.currencies.select('code, price').map { |c| { c.code => c.price } }
  end
end
