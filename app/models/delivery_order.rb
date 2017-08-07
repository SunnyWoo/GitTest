# == Schema Information
#
# Table name: delivery_orders
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  order_no       :string(255)
#  print_item_ids :integer          default([]), not null, is an Array
#  state          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'prawn'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class DeliveryOrder < ActiveRecord::Base
  include AASM

  aasm column: :state do
    state :shown
    state :hidden
  end

  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  before_validation :generate_order_no, on: :create

  def print_items
    @print_items ||= PrintItem.where(id: print_item_ids)
  end

  def generate_order_no
    timestamp = Time.zone.now.strftime('%y%m%d_%H%M%S')
    self.order_no = [product.key, timestamp].map do |str|
      str.tr('-', '_').upcase
    end.join('_')
  end

  PDF_COLUMNS = 3
  PDF_ROWS = 3

  def generate_pdf
    Prawn::Document.generate("tmp/#{order_no}.pdf", page_size: 'A4') do |pdf|
      pdf.define_grid columns: PDF_COLUMNS, rows: PDF_ROWS, gutter: 10

      last_slice = print_items.each_slice(PDF_COLUMNS * PDF_ROWS).to_a.last
      print_items.each_slice(PDF_COLUMNS * PDF_ROWS) do |slice|
        row = 0
        col = 0
        slice.each do |item|
          pdf.grid(row, col).bounding_box do
            image_path = to_jpg_path(item.order_item.itemable.order_image.url)
            pdf.image image_path, at: [0, pdf.bounds.height], width: pdf.bounds.width
            pdf.move_down pdf.bounds.width
            pdf.text "Order No. #{item.order_item.order.order_no}", align: :center
            pdf.text "Print ID: #{item.id}", align: :center
            pdf_draw_order_no_barcode(pdf, item.order.order_no) if product.imposition.try(:include_order_no_barcode?)
          end

          col = (col + 1) % PDF_COLUMNS
          row += 1 if col == 0
        end

        pdf.bounding_box [0, 0], width: 600, height: 20 do
          pdf.text order_no
        end
        pdf.start_new_page if slice != last_slice
      end
    end
  ensure
    barcode_temp_paths.blank? or begin
      barcode_temp_paths.values.each do |temp|
        temp.unlink if temp && File.exist?(temp.path)
      end
    end
  end

  def upload_path
    "ftp/#{product.dir_name}/#{order_no}"
  end

  private

  def to_jpg_path(url)
    image = MiniMagick::Image.open(url)
    image.quality 100
    image.format 'jpg'
    image.path
  end

  def pdf_draw_order_no_barcode(pdf, order_no)
    barcode_path = create_order_no_barcode_temp(order_no)
    pdf.image barcode_path, width: pdf.bounds.width, height: 30
  end

  def barcode_temp_paths
    @barcode_temp_paths ||= {}
  end

  def create_order_no_barcode_temp(order_no)
    return barcode_temp_paths[order_no].path if barcode_temp_paths.key?(order_no)
    barcode = Barby::Code128B.new(order_no)
    barcode_temp = Tempfile.new(["#{order_no}_barcode", '.png'])
    barcode_temp.binmode
    barcode_temp.write Barby::PngOutputter.new(barcode).to_png
    barcode_temp.close
    barcode_temp_paths[order_no] = barcode_temp
    barcode_temp.path
  end
end
