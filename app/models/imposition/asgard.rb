# == Schema Information
#
# Table name: impositions
#
#  id                       :integer          not null, primary key
#  model_id                 :integer
#  paper_width              :float
#  paper_height             :float
#  definition               :json
#  created_at               :datetime
#  updated_at               :datetime
#  sample                   :string(255)
#  rotate                   :integer
#  type                     :string(255)
#  template                 :string(255)
#  demo                     :boolean          default(FALSE), not null
#  file                     :string(255)
#  flip                     :boolean          default(FALSE)
#  flop                     :boolean          default(FALSE)
#  include_order_no_barcode :boolean          default(FALSE)
#

require 'prawn'
require 'prawn/measurements'

# Asgard 式拼版
# ==============
#
# 將數個作品拼在指定的位置上, 加上鑽孔點, 輸出成 PDF 後上傳.
class Imposition::Asgard < Imposition
  mount_uploader :file, PdfUploader
  def available_params
    [:paper_width, :paper_height, :rotate, :file, :flip, :flop,
     :include_order_no_barcode, positions: [:x, :y], predrill_points: [:x, :y]]
  end

  def info
    "紙張大小 #{paper_width}x#{paper_height} (mm), 共 #{positions.size} 模."
  end

  def predrill_points=(value)
    write_points('predrill_points', value)
  end

  def predrill_points
    read_points('predrill_points')
  end

  def positions=(value)
    write_points('positions', value)
  end

  def positions
    read_points('positions')
  end

  def write_points(key, value)
    write_store_attribute(:definition, key, value)
  end

  def read_points(key)
    data = read_store_attribute(:definition, key) || []
    data.map { |position| Point.new(position) }
  end

  concerning :SampleBuilder do
    included do
      include Prawn::Measurements
      mount_uploader :sample, PdfUploader
    end

    def build_sample
      page_size = [mm2pt(paper_width), mm2pt(paper_height)]
      output_file = "tmp/#{updated_at.to_i}.pdf"

      w = mm2pt(product_width)
      h = mm2pt(product_height)
      Prawn::Document.generate(output_file, page_size: page_size,
                                            page_layout: :landscape,
                                            margin: 0) do |doc|
        positions.each do |p|
          doc.rotate rotate.to_i, origin: [mm2pt(p.x), mm2pt(p.y)] do
            draw_sample_rectangle(doc, mm2pt(p.x), mm2pt(p.y), w, h)
          end
        end

        predrill_points.each do |p|
          draw_sample_circle(doc, mm2pt(p.x), mm2pt(p.y))
        end
      end
      combine_with_pdf_template(output_file) if file.present? and file.pdf?
      update(sample: File.open(output_file), skip_build_sample: true)
    end

    # x, y 應為中心點位置
    def draw_sample_rectangle(doc, x, y, w, h)
      hw = w / 2
      hh = h / 2
      x -= hw
      y -= hh

      doc.stroke do
        doc.rectangle [x, y + h], w, h
        doc.move_to x, y + h
        doc.line_to x + w, y
        doc.move_to x + w, y + h
        doc.line_to x, y
      end
    end

    # x, y 應為中心點位置
    def draw_sample_circle(doc, x, y)
      doc.stroke do
        doc.circle [x, y], 5
      end
    end
  end

  concerning :PrintableBuilder do
    included do
      include Prawn::Measurements
      WHITE_VERSION_PREFIX = 'white-'.freeze
      BACK_IMAGE_PREFIX = 'back_image-'.freeze
    end

    def slice_size
      positions.size
    end

    def each_slice_with_index(items, &block)
      items.each_slice(slice_size).each_with_index(&block)
    end

    def slice_count(items)
      items.each_slice(slice_size).size
    end

    def build_printable(items)
      page_size = [mm2pt(paper_width), mm2pt(paper_height)]
      pdf_makers = generate_pdf_makers(items)
      pdf_makers.each do |pdf_maker|
        Prawn::Document.generate(pdf_maker.folder_with_file, page_size: page_size,
                                                             page_layout: :landscape,
                                                             margin: 0) do |doc|
          items.zip(positions).each do |(item, p)|
            doc.rotate rotate.to_i, origin: [mm2pt(p.x), mm2pt(p.y)] do
              draw_item(doc, pdf_maker.image_url(item), mm2pt(p.x), mm2pt(p.y))
            end
          end

          predrill_points.each do |p|
            draw_circle(doc, mm2pt(p.x), mm2pt(p.y))
          end
        end
      end
      combine_with_pdf_template(pdf_makers.map(&:folder_with_file)) if file.present? and file.pdf?
      pdf_makers.map(&:folder_with_file)
    end

    # x, y 應為中心點位置
    def draw_item(doc, image_url, x, y)
      image = MiniMagick::Image.open(image_url)
      image.interlace('none')

      VERSIONS.each do |version|
        image.send(version) if send(version)
      end
      w = in2pt(image[:width] / product_dpi.to_f)
      h = in2pt(image[:height] / product_dpi.to_f)
      hw = w / 2
      hh = h / 2
      x -= hw
      y -= hh

      doc.image image.path, at: [x, y + h], width: w, height: h
    end

    # x, y 應為中心點位置
    def draw_circle(doc, x, y)
      draw_sample_circle(doc, x, y)
    end

    ImpositionPDFMaker = Struct.new :file, :version do
      def self.create(file, version: nil)
        new(file, version)
      end

      def image_url(item)
        return item.print_image.escaped_url unless version
        if version == :back_image
          item.back_image_path
        else
          item.print_image.try(version).escaped_url
        end
      end

      def folder_with_file
        File.join('tmp', file)
      end
    end

    def generate_pdf_makers(items)
      file = "#{items.map(&:id).join('-')}.pdf"
      makers = []
      makers << pdf_maker.create(file)
      makers << pdf_maker.create(white_version(file), version: :gray) if product.enable_white?
      makers << pdf_maker.create(back_image_version(file), version: :back_image) if product.enable_back_image?
      makers
    end

    def white_version(filename)
      WHITE_VERSION_PREFIX + filename
    end

    def back_image_version(filename)
      BACK_IMAGE_PREFIX + filename
    end

    def pdf_maker
      ImpositionPDFMaker
    end
  end

  protected

  def combine_with_pdf_template(output_files)
    output_files = Array(output_files) unless output_files.is_a?(Array)
    pdf_template_file = download_template_file
    begin
      output_files.each do |output_file|
        items_content = CombinePDF.load(output_file).pages[0]
        template = CombinePDF.load(pdf_template_file)
        template.pages[0] << items_content
        template.save(output_file)
      end
    ensure
      File.delete(pdf_template_file) if pdf_template_file and File.exist?(pdf_template_file)
    end
  end

  def download_template_file
    pdf_template = open(file.escaped_url)
    pdf_template_file = "#{UUIDTools::UUID.timestamp_create.to_s.delete('-')}-template.pdf"
    File.open(pdf_template_file, 'wb') do |file|
      file.write pdf_template.read
    end
    pdf_template_file
  end
end
