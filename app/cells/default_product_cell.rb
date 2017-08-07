class DefaultProductCell < Cell::Rails
  include CurrentCurrencyCode

  def product
    @default_product = ProductModel.find_by(key: 'iphone_6_cases')
    @img_files ||= Dir.glob('app/assets/images/home/default_product/*.jpg')
    render
  end

  def model_image_file(product)
    'editor/devices/img-' + product.name.gsub(/\s|\//, '-').downcase + '.png'
  end

  helper_method :model_image_file
  helper ProductModelHelper
  helper ApplicationHelper
end
