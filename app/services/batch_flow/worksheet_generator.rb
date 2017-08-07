require 'barby/barcode/code_128'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'

class BatchFlow::WorksheetGenerator
  include BatchFlow::Utils

  delegate :order_no, :print_items, to: :batch

  CHINESE_FONT_PATH = Rails.root.join('app/assets/fonts', 'cwTeXHei-zhonly.ttf').to_s
  CHINESE_FONT_PATH2 = Rails.root.join('app/assets/fonts', 'fang-jeng-jeng-hei.ttf').to_s

  DEFAULT_DOCUMENT_OPTIONS = {
    layout: {
      page_size: 'A4',
      page_layout: :portrait,
      margin: 0,
    },
    grid: {
      columns: 2,
      rows: 5,
      gutter: 3
    }
  }.freeze

  BARCODE_WIDTH_PERCENTAGE = 0.66
  BARCODE_HEIGHT = 20
  QRCODE_WIDTH = 45
  QRCODE_HEIGHT = 45
  PHOTO_WIDTH_PERCENTAGE = 0.4
  TEXTBOX_PADDING = 10

  def initialize(batch, product, print_items, options = {})
    @batch, @product, @print_items, @options = batch, product, print_items, options
  end

  def generate!(options = {})
    @options.merge!(options)
    @image_path_cache = {}
    @barcode_path_cache = {}
    @qrcode_path_cache = {}

    @pdf = Prawn::Document.new(document_options[:layout])
    @pdf.font_families.update(
      "hei" => {
        normal: { file: CHINESE_FONT_PATH, font: "Hei" }
      },
      "hei2" => {
        normal: { file: CHINESE_FONT_PATH2, font: "Hei2" }
      }
    )

    @pdf.define_grid document_options[:grid].slice(:columns, :rows, :gutter)

    @print_items.each_slice(columns * rows).each_with_index do |items_per_page, i|
      @pdf.start_new_page unless i.zero?
      generate_page(items_per_page)
    end

    @pdf.render_file(destination)
  ensure
    clean_cached_files
  end

  def document_options
    @document_options ||= begin
      DEFAULT_DOCUMENT_OPTIONS.dup.tap do |opts|
        opts[:layout].merge!(Hash(@options[:layout]))
        opts[:grid].merge!(Hash(@options[:grid]))
      end
    end
  end

  def destination; "#{path}/#{filename.tr('/', '_')}.pdf"; end

  private

  def i18n_scope; 'print.batch_flow.worksheet'; end

  def font_style
    {
      align: :left,
      size: 10,
      fallback_fonts: fallback_fonts
    }
  end

  # hei2 為簡體字形
  # hei 為繁體字形
  def fallback_fonts
    if @batch.locale == 'zh-CN'
      %w(hei2 hei)
    else
      %w(hei hei2)
    end
  end

  def generate_page(items)
    row, col = 0, 0

    items.each do |item|
      @pdf.grid(row, col).bounding_box do
        image_path = fetch_print_image_path(item)

        width  = @pdf.bounds.width
        height = @pdf.bounds.height

        image_width = image_height = (width * PHOTO_WIDTH_PERCENTAGE)

        barcode_width = (width * BARCODE_WIDTH_PERCENTAGE)
        barcode_height = BARCODE_HEIGHT
        barcode_position_x = barcode_width * ((1 - BARCODE_WIDTH_PERCENTAGE) / 2)

        qrcode_width =  QRCODE_WIDTH
        qrcode_height = QRCODE_HEIGHT

        barcode_image_options = { width: barcode_width, height: barcode_height, margin: 0 }
        qrcode_image_options = { width: qrcode_width, height: qrcode_height, margin: 0 }

        order_number_barcode_path = fetch_order_number_barcode(item, barcode_image_options)
        fetch_print_number_qrcode = fetch_print_number_qrcode(item, qrcode_image_options)

        @pdf.image image_path, at: [0, height], width: image_width, height: image_height

        @pdf.image order_number_barcode_path, at: [barcode_position_x, barcode_height + 20], width: barcode_width, height: barcode_height

        item_code = generate_item_code(item.order, item.order_item_serial, item.product, item.order_item.quantity)
        item_number = "#{item_code}-#{item.quantity_serial}"

        @pdf.move_down TEXTBOX_PADDING
        @pdf.bounding_box([image_width, @pdf.cursor], width: width - image_width - TEXTBOX_PADDING * 2) do
          @pdf.text "BNO: #{@batch.number_with_source}", font_style
          @pdf.move_down 3
          @pdf.text "CID: #{item.order.order_no}", font_style
          @pdf.move_down 3
          @pdf.text "UID: #{item_number}", font_style
          @pdf.move_down 3
          @pdf.text "Model: #{item.product.name}", font_style
        end

        @pdf.image fetch_print_number_qrcode, at: [width - QRCODE_WIDTH - 40, height - image_height / 2 - 10], width: qrcode_width, height: qrcode_height

        @pdf.bounding_box([barcode_position_x, 15], width: barcode_width) do
          @pdf.text item.order.order_no, font_style.merge(align: :center, size: 6)
        end
      end

      col = (col + 1) % columns
      row += 1 if col.zero?
    end
  end

  def fetch_print_image_path(print_item)
    order_item_id = print_item.order_item_id
    cached_path = @image_path_cache[order_item_id]

    if cached_path && File.exist?(cached_path)
      cached_path
    else
      url = print_item.order_item.itemable.order_image.url
      cached_path = Rails.root.join("tmp", "order_item_print_image_#{order_item_id}.jpg")
      image = MiniMagick::Image.open(url)
      image.quality 100
      image.format 'jpg'
      image.write cached_path
      @image_path_cache[order_item_id] = cached_path
    end
  end

  def fetch_order_number_barcode(print_item, options = {})
    order = print_item.order
    cached_path = @barcode_path_cache[order.id]

    if cached_path && File.exist?(cached_path)
      cached_path
    else
      barcode = Barby::Code128B.new(order.order_no)
      cached_path = Rails.root.join("tmp", "order_barcode_#{order.id}.png")
      File.open(cached_path, 'wb') { |f| f.write Barby::PngOutputter.new(barcode).to_png(options) }
      @barcode_path_cache[order.id] = cached_path
    end
  end

  def fetch_print_number_qrcode(print_item, options = {})
    barcode = Barby::QrCode.new(print_item.timestamp_no.to_s)
    path = Rails.root.join("tmp", "print_item_qrcode_#{print_item.id}.png")
    File.open(path, 'wb') { |f| f.write Barby::PngOutputter.new(barcode).to_png(options) }
    @qrcode_path_cache[print_item.id] = path
  end

  def clean_cached_files
    (@image_path_cache.values + @barcode_path_cache.values + @qrcode_path_cache.values).each do |cached_file|
      File.delete(cached_file) if File.exist?(cached_file)
    end
  end

  def columns; document_options[:grid].fetch(:columns); end

  def rows; document_options[:grid].fetch(:rows); end

  def path; @options.fetch(:path, 'tmp'); end

  def filename
    @options.fetch(:filename){
      I18n.t(
        'filename',
        scope: i18n_scope,
        batch_number: @batch.number,
        product_name: @product.name,
        source: source_location_code
      )
    }
  end
end
