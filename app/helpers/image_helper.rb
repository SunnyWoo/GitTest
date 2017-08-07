module ImageHelper
  def image_webp(image, options={})
    begin
      web_options = { 'img-original': image.url, 'img-webp': image.webp.url, 'use-image-webp': true }
      options[:data] = web_options.merge(options[:data] || {})
      image_tag(nil, options)
    rescue => e
      image_tag(image, options)
    end
  end
end
