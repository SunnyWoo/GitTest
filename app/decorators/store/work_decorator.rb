class Store::WorkDecorator < Draper::Decorator
  delegate_all

  def name
    "#{object.name} #{object.product_name}"
  end

  def description
    case object
    when Work
      object.product_template.description
    when StandardizedWork
      object.content
    else
      '商品描述尚未提供'
    end
  end

  def model_description
    object.product_description
  end

  def model_images
    object.product.description_images.map(&:image)
  end
end
