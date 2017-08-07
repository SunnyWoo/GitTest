require 'mini_magick'
require 'open-uri'

module ImageService
  class StoreFooter
    include ImageService::MiniMagick::ImageFactory
    include ImageService::MiniMagick::Helpers

    attr_reader :store

    def initialize(store)
      @store = store
    end

    def generate
      tmp_paths = []
      canvas = create_blank_image(640, 100)
      tmp_paths << canvas.path
      # 合成 store log
      logo = ::MiniMagick::Image.open(store.logo.url)
      logo.combine_options do |c|
        c.scale '80x80'
      end
      canvas = canvas.composite(logo) do |c|
        c.gravity 'NorthWest'
        c.geometry to_position(10, 10)
      end
      tmp_paths << canvas.path
      tmp_paths << logo.path

      # 合成 qrcode
      url_qrcode_path = store.url_qrcode_path
      qrcode = ::MiniMagick::Image.open(url_qrcode_path)
      qrcode.combine_options do |c|
        c.scale '80x80'
      end
      canvas = canvas.composite(qrcode) do |c|
        c.gravity 'NorthWest'
        c.geometry to_position(550, 10)
      end
      tmp_paths << canvas.path
      tmp_paths << url_qrcode_path
      tmp_paths << qrcode.path

      tempfile = Tempfile.new(['store_footer_img', '.png'])
      canvas.write(tempfile.path)
      tmp_paths.each { |path| File.delete(path) }
      tempfile
    end
  end
end
