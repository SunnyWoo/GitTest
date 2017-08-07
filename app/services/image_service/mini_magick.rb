require 'mini_magick'
require 'open-uri'

module ImageService
  class MiniMagick
    include ImageFactory
    include Helpers

    INCH_TO_MM = 25.4
    MM_TO_INCH = 1 / INCH_TO_MM
    PREFERED_DPI = '300'.freeze
    DEFAULT_FONT_SIZE = 108
    APP_TO_REAL_SCALE = 2 # TODO: 魔術數字，Workaround
    ICC_PROFILE = 'PSO_Coated_300_NPscreen_ISO12647_eci.icc'.freeze
    DEFAULT_OPTIONS = {
      skip_watermark: false,
      mirror_image: false
    }.freeze

    attr_reader :work, :work_spec, :width, :height

    def initialize(work)
      @work = work
      @work_spec = @work.work_spec
      @width = work_spec.dpi_width
      @height = work_spec.dpi_height
    end

    def generate(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      canvas = create_blank_image(width, height, color: work_spec.background_color)

      # 設定格式
      # canvas.format 'png'

      # 設定品質
      canvas.quality '100'

      # 設定 DPI
      canvas.combine_options do |c|
        c.units 'PixelsPerInch'
        c.density work_spec.dpi
      end

      # 合成圖層
      layers = get_work_layers(work)
      canvas = generate_image_from_layers(canvas, layers)

      # 合成 product_template only Work, ArchivedWork
      canvas = process_product_template(canvas) if work.product_template_exist?

      # 合成對齊點
      canvas = process_alignment_points(canvas)

      # 合成遮罩
      canvas = process_crop_print_image(canvas)

      # 組成雙面拼接模式
      canvas = process_composite_with_mirror_image(canvas) if options[:mirror_image].to_b

      # 合成浮水印
      canvas = process_watermark(canvas) unless options[:skip_watermark].to_b

      # 設定色彩空間為 sRGB
      canvas.combine_options do |c|
        c.colorspace 'sRGB'
      end

      tempfile = Tempfile.new(['print_image', '.png'])
      canvas.write(tempfile.path)

      tempfile
    end

    def generate_image_from_layers(canvas, layers)
      layers.inject(canvas) do |prev_canvas, layer|
        Rails.logger.debug "Processing #{layer.layer_type} layer..."
        send("process_#{layer.layer_type}_layer", prev_canvas, layer)
      end
    end

    # TODO: 支援多設備 + 重構
    def generate_order_image
      OrderImageGenerator.new(work).generate
    end

    def process_camera_layer(canvas, layer)
      image = ::MiniMagick::Image.open(layer.filtered_image.escaped_url)
      image.scale(to_percent(APP_TO_REAL_SCALE))

      process_image_layer(canvas, layer, image)
    end

    # for StandardizedWork build_print_image
    def process_fake_layer(canvas, layer)
      image = ::MiniMagick::Image.open(layer.filtered_image.file.path)
      image.scale(to_percent(APP_TO_REAL_SCALE))

      process_image_layer(canvas, layer, image)
    end

    alias_method :process_photo_layer, :process_camera_layer

    def process_background_color_layer(canvas, layer)
      canvas.combine_options do |c|
        c.fill layer.color_with_alpha
        c.draw "rectangle 0,0,#{width},#{height}"
      end
      canvas
    end

    %w(shape line sticker texture typography frame colorsticker).each do |attr|
      define_method "process_#{attr}_layer" do |canvas, layer|
        image = ::MiniMagick::Image.open(layer_material_path(layer))
        process_image_layer(canvas, layer, image)
      end
    end

    def process_crop_layer(canvas, layer)
      # 讀出 Crop 圖，依 Layer 做 resize/rotate
      image = ::MiniMagick::Image.open(layer_material_path(layer))
      image.resize to_percent_geometry(layer.scale_x.abs, layer.scale_y.abs)
      image.rotate layer.orientation

      # 依R&R後的圖建等尺寸的鏤空區
      hollow = create_blank_image(image.width, image.height, color: layer.cast_color)

      # 產生只有鏤空區的全圖
      hollow_canvas = create_blank_image(width, height, color: 'none').composite(hollow) do |c|
        c.gravity 'Center'
        c.geometry to_position(layer.position_x, layer.position_y)
      end

      # 產生只有 crop 圖的全圖
      image_canvas = create_blank_image(width, height, color: 'none').composite(image) do |c|
        c.gravity 'Center'
        c.geometry to_position(layer.position_x, layer.position_y)
      end

      # 組合成crop全圖，以依白色代表遮罩 + 透明資訊
      crop = create_blank_image(width, height, color: 'white').composite(hollow_canvas) do |c|
        c.compose 'dst-out'
      end.composite(image_canvas)

      # 建立與設備同大小的純色背景圖
      crop_background = create_blank_image(width, height, color: layer.cast_color)

      # 用純色背景 + Crop 範圍合成真正的 Layer 顏色的 Crop 圖
      crop_scope_image = crop.composite(crop_background) do |c|
        c.compose 'src-in'
      end

      # 將 Crop 圖疊上 Canvas
      canvas.composite(crop_scope_image)
    end

    def process_text_layer(canvas, layer)
      if layer.filtered_image.present?
        image = ::MiniMagick::Image.open(layer.filtered_image.escaped_url)

        Rails.logger.debug 'Combining...'
        image.combine_options do |c|
          # 縮放
          # android端的客制化作品才需要缩放
          if customized_work_from_android? && layer.scale_x != 0 && layer.scale_y != 0
            c.scale to_percent_geometry(layer.scale_x.abs, layer.scale_y.abs)
            c.flop if layer.scale_x < 0
            c.flip if layer.scale_y < 0
          end

          # 旋轉
          if layer.orientation != 0
            c.background 'none'
            c.rotate layer.orientation
          end
        end

        Rails.logger.debug 'Compositing...'
        canvas.composite(image) do |c|
          c.gravity 'Center'
          c.geometry to_position(layer.position_x, layer.position_y)
        end
      else
        image = create_text_image(layer.font_text,
                                  layer.font_path,
                                  align: layer.text_alignment)
        process_image_layer(canvas, layer, image)
      end
    end

    def process_lens_flare_layer(canvas, _layer)
      # TODO: 還沒做
      canvas
    end

    def process_spot_casting_layer(canvas, _layer)
      # TODO: 還沒做
      canvas
    end

    def process_spot_casting_text_layer(canvas, _layer)
      # TODO: 還沒做
      canvas
    end

    def process_image_layer(canvas, layer, image, colorizable: true)
      Rails.logger.debug 'Converting...'
      image.auto_orient
      image.format 'png'

      Rails.logger.debug 'Combining...'
      image.combine_options do |c|
        # 上色
        if colorizable && !(layer.photo? || layer.camera?) && layer.color?
          c.fill layer.cast_color
          c.colorize '100%'
        end

        # 縮放
        if layer.scale_x != 0 && layer.scale_y != 0
          c.scale to_percent_geometry(layer.scale_x.abs, layer.scale_y.abs)
          c.flop if layer.scale_x < 0
          c.flip if layer.scale_y < 0
        end

        # 旋轉
        if layer.orientation != 0
          c.background 'none'
          c.rotate layer.orientation
        end
      end

      Rails.logger.debug 'Compositing...'
      canvas.composite(image) do |c|
        c.gravity 'Center'
        c.geometry to_position(layer.position_x, layer.position_y)

        # 透明
        c.dissolve to_blend_value(layer.transparent)
      end
    end

    def process_varnishing_typography_layer(canvas, _layer)
      # 不需要在這裡做
      canvas
    end

    def process_varnishing_layer(canvas, _layer)
      # 不需要在這裡做
      canvas
    end

    def process_bronzing_typography_layer(canvas, _layer)
      # 不需要在這裡做
      canvas
    end

    def process_bronzing_layer(canvas, _layer)
      # 不需要在這裡做
      canvas
    end

    def process_sticker_asset_layer(canvas, layer)
      asset = Asset.find_by!(uuid: layer.material_name)
      image = ::MiniMagick::Image.open(asset.raster.escaped_url)
      process_image_layer(canvas, layer, image, colorizable: asset.colorizable)
    end

    alias_method :process_coating_asset_layer, :process_sticker_asset_layer

    def process_foiling_asset_layer(canvas, _layer)
      # 不需要在這裡做
      canvas
    end

    def process_mask_layer(canvas, layer)
      blank = create_blank_image(layer.mask_image.width, layer.mask_image.height, color: 'none')
      masked_image = generate_image_from_layers(blank, layer.masked_layers)
      mask = ::MiniMagick::Image.open(layer.mask_image.escaped_url)
      image = mask.composite(masked_image, '.png') do |c|
        c.compose 'src-in'
      end
      process_image_layer(canvas, layer, image)
    end

    def process_crop_print_image(canvas)
      return canvas if work_spec.print_image_mask.blank?

      mask = ::MiniMagick::Image.open(work_spec.print_image_mask.escaped_url)
      mask.resize("#{width}x#{height}!")

      # 建立空白背景
      background = create_blank_image(width, height, color: work_spec.background_color)

      # 設定格式
      background.format 'png'

      # 設定品質
      background.quality '100'

      # 設定 DPI
      background.combine_options do |c|
        c.units 'PixelsPerInch'
        c.density '300'
      end

      # 大合成
      background.composite(canvas, '.png', mask) do |c|
        c.gravity 'Center'
      end
    end

    def process_watermark(canvas)
      return canvas if work_spec.watermark.blank?
      watermark = ::MiniMagick::Image.open(work_spec.watermark.escaped_url)
      canvas.composite(watermark) do |c|
        c.gravity 'Center'
      end
    end

    def process_alignment_points(canvas)
      Rails.logger.debug 'Drawing alignment points...'
      case work_spec.alignment_points
      when 'none'     then canvas
      when 'solo_bot' then process_alignment_points_solo_bot(canvas)
      else fail "The alignment points `#{work_spec.alignment_points}` is not yet implemented!"
      end
    end

    def process_alignment_points_solo_bot(canvas)
      x = @width / 2
      y = @height

      canvas = canvas.combine_options do |c|
        c.fill 'rgba(255,255,255,0.3)'
        c.draw "rectangle #{x},#{y} #{x - 15},#{y - 35}"
      end
      canvas.combine_options do |c|
        c.fill 'rgba(0,0,0,0.3)'
        c.draw "rectangle #{x},#{y} #{x + 15},#{y - 35}"
      end
    end

    def layer_material_path(layer)
      layer.commandp_resources_material_image_path
    end

    def get_work_layers(work)
      case work.class.name
      when 'Work', 'ArchivedWork'
        work.layers.root.positive.enabled.select(&:printable?)
      when 'StandardizedWork', 'ArchivedStandardizedWork'
        work.build_fake_layers
      end
    end

    def process_composite_with_mirror_image(canvas)
      mirror_image_path = Tempfile.new(['mirror_print_image', '.png']).path
      ::MiniMagick::Image.open(canvas.path).rotate(180).write mirror_image_path
      Rails.logger.debug 'Compositing with mirror print image...'
      begin
        ::MiniMagick::Tool::Convert.new do |convert|
          convert << canvas.path
          convert << mirror_image_path
          convert.merge! ["-append"]
          convert << canvas.path
        end
        canvas
      ensure
        File.delete mirror_image_path if mirror_image_path and File.exist?(mirror_image_path)
      end
    end

    # android端的客制化作品
    def customized_work_from_android?
      return false unless work.class.name.in? %w(Work ArchivedWork)
      work.application.try(:name).to_s.casecmp('android').zero?
    end

    def process_product_template(canvas)
      Rails.logger.debug 'Process ProductTemplate ...'
      image = ::MiniMagick::Image.open(work.product_template.template_image.url)
      canvas.composite(image) do |c|
        c.gravity 'Center'
        c.geometry to_position(0, 0)
      end
    end
  end
end
