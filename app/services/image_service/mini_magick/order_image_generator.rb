class ImageService::MiniMagick::OrderImageGenerator
  include ImageService::MiniMagick::ImageFactory

  MODEL_TO_METHOD = {
    'iPhone 6 Plus' => :generate_iphone_6_plus_order_image,
    'iPhone 6'      => :generate_iphone_6_order_image,
    'iPhone 5s/5'   => :generate_iphone_5s_order_image,
    'iPhone 4s/4'   => :generate_iphone_4_order_image,
    'iPad mini'     => :generate_ipad_mini_order_image
  }

  attr_reader :work

  def initialize(work)
    @work = work
  end

  def generate
    send(MODEL_TO_METHOD[work.product_name] || :generate_default_order_image)
  end

  def generate_default_order_image
    generate_iphone_6_plus_order_image
  end

  def genrate_front_back_order_image(args)
    tempfile = Tempfile.new(['order_image', '.jpg'])
    # 外殼
    Rails.logger.debug 'Loading case image...'
    case_image = open_image(args[:case])
    # 左半部遮罩
    Rails.logger.debug 'Loading case left mask image...'
    case_left_mask = create_mask(args[:left_mask])
    # 右半部遮罩
    Rails.logger.debug 'Loading case right mask image...'
    case_right_mask = create_mask(args[:right_mask])
    # 底圖
    Rails.logger.debug 'Creating blank image...'
    canvas = create_blank_image(case_image[:width], case_image[:height])
    # 作品
    Rails.logger.debug 'Loading print image...'
    cover = ::MiniMagick::Image.open(work.print_image.url)
    # NOTE: commandp_app_printarea_尺寸標註 中的尺寸值皆為除以二的結果
    # 左邊
    Rails.logger.debug 'Drawing left cover...'
    cover.resize size_from_dimension(args[:left_dimension])
    canvas = canvas.composite(cover, '.jpg', case_left_mask) do |c|
      c.geometry position_from_dimension(args[:left_dimension])
    end
    # 右邊
    Rails.logger.debug 'Drawing right cover...'
    cover.resize size_from_dimension(args[:right_dimension])
    canvas = canvas.composite(cover, '.jpg', case_right_mask) do |c|
      c.geometry position_from_dimension(args[:right_dimension])
    end
    # 外殼
    Rails.logger.debug 'Drawing case...'
    canvas = canvas.composite(case_image)
    # 寫入並傳回暫時檔案
    Rails.logger.debug 'Exporting...'
    canvas.write(tempfile.path)
    tempfile
  end

  def size_from_dimension(dimension)
    "#{dimension[2] * 2}x"
  end

  def position_from_dimension(dimension)
    "%+d%+d" % [dimension[0].to_i * 2, dimension[1].to_i * 2]
  end

  def generate_iphone_6_plus_order_image
    Rails.logger.debug 'Building iPhone 6 Plus order image...'
    genrate_front_back_order_image(case: 'i6_plus/case',
                                   left_mask: 'i6_plus/left_mask',
                                   right_mask: 'i6_plus/right_mask',
                                   left_dimension: [3, -6, 185, 334],
                                   right_dimension: [124, -12, 192, 346])
  end

  def generate_iphone_6_order_image
    Rails.logger.debug 'Building iPhone 6 order image...'
    genrate_front_back_order_image(case: 'i6/case',
                                   left_mask: 'i6/left_mask',
                                   right_mask: 'i6/right_mask',
                                   left_dimension: [8, 4, 183, 314],
                                   right_dimension: [124, -2, 189, 325])
  end

  def generate_iphone_5s_order_image
    Rails.logger.debug 'Building iPhone 5S order image...'
    genrate_front_back_order_image(case: 'i5s/case',
                                   left_mask: 'i5s/left_mask',
                                   right_mask: 'i5s/right_mask',
                                   left_dimension: [0, -22, 196, 353],
                                   right_dimension: [116, -28, 202, 363])
  end

  def generate_iphone_4_order_image
    Rails.logger.debug 'Building iPhone 4 order image...'
    genrate_front_back_order_image(case: 'i4/case',
                                   left_mask: 'i4/left_mask',
                                   right_mask: 'i4/right_mask',
                                   left_dimension: [-5, -5, 207, 338],
                                   right_dimension: [118, -10, 211, 346])
  end

  def generate_ipad_mini_order_image
    Rails.logger.debug 'Building iPad Mini order image...'
    genrate_front_back_order_image(case: 'ipad_mini/case',
                                   left_mask: 'ipad_mini/left_mask',
                                   right_mask: 'ipad_mini/right_mask',
                                   left_dimension: [-6, 8, 219, 306],
                                   right_dimension: [100, 4, 224, 313])
  end

  def open_image(name)
    ::MiniMagick::Image.open(Rails.root + "vendor/order_image_materials/#{name}.png")
  end

  def create_mask(name)
    mask = open_image(name)
    mask.background 'black'
    mask.flatten
    mask
  end
end
