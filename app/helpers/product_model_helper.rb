module ProductModelHelper
  def get_model_image_url(product)
    if product.placeholder_image.present?
      product_image_url = product.placeholder_image.url
    else
      product_image_url = 'editor/devices/img-' + product.key.gsub(/\s|\//, '-').downcase + '.png'
    end
    image_url(product_image_url)
  end

  def render_product_price(product, currency_code: current_currency_code)
    render_price(product.price_in_currency(currency_code), currency_code: currency_code)
  end

  def render_product_customized_special_price(product, currency_code: current_currency_code)
    render_price(product.customized_special_price(currency_code), currency_code: currency_code)
  end
end
