class ImageService::MiniMagick::BackImageGenerator
  include ImageService::MiniMagick::ImageFactory
  include ImageService::MiniMagick::Helpers

  MODEL_TO_METHOD = {
    'sptc_smartcards' => :generate_sptc_smartcards_back_image
  }.freeze

  attr_reader :print_item

  delegate :timestamp_no, :product_key, to: :print_item

  def initialize(print_item)
    @print_item = print_item
  end

  def execute
    send(MODEL_TO_METHOD[product_key])
  end

  private

  def generate_sptc_smartcards_back_image
    Rails.logger.debug 'Building sptc smartcard back image...'
    tempfile = generate_tmpfile
    Rails.logger.debug 'Loading case image...'
    case_image = open_image
    # 底圖
    Rails.logger.debug 'Creating blank image...'
    canvas = create_blank_image(case_image[:width], case_image[:height], color: 'none')
    # 将动态码放入指定位置, 默认使用 helvetica 字体
    Rails.logger.debug 'Drawing code cover...'
    code_image = create_text_image(code, "#{Rails.root}/app/assets/fonts/Helvetica_LT.ttf", align: 'Right')
    code_image.combine_options do |c|
      c.colorize '100%'
      c.scale to_percent_geometry(0.05, 0.05)
    end
    canvas = canvas.composite(case_image)
    canvas = canvas.composite(code_image) do |c|
      c.geometry to_position(case_image[:width] - 245, 150)
    end
    # 寫入並傳回暫時檔案
    Rails.logger.debug 'Exporting...'
    canvas.write(tempfile.path)
    tempfile.path
  ensure
    tempfile.close
  end

  def open_image
    ::MiniMagick::Image.open(Rails.root + "vendor/back_image_materials/#{product_key}.png")
  end

  def code
    PrintItem::CodeHandler.encode(timestamp_no)
  end

  def generate_tmpfile
    path = "tmp/#{filename}.png"
    File.new(path, 'w+')
  end

  def filename
    ['back_image', timestamp_no].join('')
  end
end
