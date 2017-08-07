class AddPrintImageMaskToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :print_image_mask, :string

    ProductModel.all.each do |product|
      case
      when product.extra_info['shape'] == 'ellipse'
        mask = create_ellipse_mask(product)
        product.update(print_image_mask: File.open(mask.path))
      when product.enable_white?
        begin
          mask_file = File.open("#{Rails.root}/vendor/mask/#{product.key}.png")
          product.update(print_image_mask: mask_file)
        rescue Exception => e
        end
      end
    end
  end

  def create_ellipse_mask(product)
    width = product.extra_info['width'] / 25.4 * product.extra_info['dpi']
    height = product.extra_info['height'] / 25.4 * product.extra_info['dpi']
    half_width = width / 2
    half_height = height / 2
    p1x = half_width
    p1y = half_height
    p2x = p1x
    p2y = height
    factory = Object.new.extend(ImageService::MiniMagick::ImageFactory)
    factory.create_shape_image(width, height, draw: "circle #{p1x},#{p1y} #{p2x},#{p2y}")
  end
end
