require 'prawn'

class PdfService
  private

  def prepare_image
    @width = @work.product_width
    @height = @work.product_height
  end

  class << self
    def generate(order_item_id)
      order_item = OrderItem.find(order_item_id)
      work = order_item.itemable
      pdf_file = "#{Time.now.to_i}.pdf"
      pdf = Prawn::Document.new
      file_extension = work.cover_image.url.last(3)
      file_name = "temp-#{Time.now.to_i}.#{file_extension}"
      thumb_file_name = "thumb-temp-#{Time.now.to_i}.#{file_extension}"
      File.open(file_name, 'wb') do |file|
        if Rails.env.development?
          file.write open('http://localhost:3000' + work.cover_image.url).read
        else
          file.write open(work.cover_image.url).read
        end
      end
      File.open(thumb_file_name, 'wb') do |file|
        if Rails.env.development?
          file.write open('http://localhost:3000' + work.cover_image.thumb.url).read
        else
          file.write open(work.cover_image.thumb.url).read
        end
      end
      pdf.table [
        [{ image: file_name }, { image: thumb_file_name }, order_item.id]
      ]
      pdf.render_file pdf_file
      order_item.pdf = File.open(pdf_file)
      order_item.save!
    end
  end
end
