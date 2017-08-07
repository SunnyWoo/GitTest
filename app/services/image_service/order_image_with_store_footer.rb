require 'mini_magick'
require 'open-uri'

module ImageService
  class OrderImageWithStoreFooter
    include ImageService::MiniMagick::ImageFactory
    include ImageService::MiniMagick::Helpers

    attr_reader :store, :work

    def initialize(work)
      @work = work
      @store = work.product_template.store
    end

    def generate
      canvas = create_blank_image(640, 740)
      # 合成 order-image
      order_image = ::MiniMagick::Image.open(work.order_image.url)
      canvas = canvas.composite(order_image) do |c|
        c.gravity 'NorthWest'
        c.geometry to_position(0, 0)
      end
      File.delete(order_image.path)

      # 合成 store_footer_img
      store_footer_img = ::MiniMagick::Image.open(store.store_footer_img.url)
      canvas = canvas.composite(store_footer_img) do |c|
        c.gravity 'NorthWest'
        c.geometry to_position(0, 640)
      end
      File.delete(store_footer_img.path)

      tempfile = Tempfile.new(['store_footer_img', '.png'])
      canvas.write(tempfile.path)
      tempfile
    end
  end
end
