class PrinterUploaderService
  attr_reader :print_item, :file_gateway

  delegate :id, :timestamp_no, :product, :order, :order_item, :print_image,
           :order_image, :back_image_path, :output_files, :get_print_image,
           :get_output_files, :get_white_image, to: :print_item

  def initialize(print_item_id, file_gateway_id)
    @print_item = PrintItem.find(print_item_id)
    @file_gateway = FileGateway.find(file_gateway_id)
  end

  def execute
    files = upload_files_collection.reverse
    path = "ftp/#{product.dir_name}/#{order.order_no}"
    begin
      files.each { |file| file_gateway.upload(file, path: path) }
      print_item.print!
    rescue => e
      print_item.create_activity(:print_error, message: "Error:#{e}")
      Rollbar.error(e) unless Rails.env.development?
    ensure
      files.each { |file| File.delete(file) if File.exist?(file) }
    end
  end

  private

  def download_files_to_upload(style)
    urls = urls_for_download(style)
    names = []
    urls.each_with_index do |url, index|
      file_extension = File.extname(URI.parse(url).path)
      file_name = tmp_file_name(style, file_extension, index: index)
      File.open(file_name, 'wb') { |file| file.write open(url).read }
      names << file_name
    end
    names
  end

  def tmp_file_name(style, file_extension, index: 0)
    case style
    when 'output_files'
      "tmp/#{order.order_no}-#{id}-#{index}#{file_extension}"
    when 'white_image'
      "tmp/#{timestamp_no}-#{id}-white#{file_extension}"
    else
      "tmp/#{timestamp_no}-#{id}#{file_extension}"
    end
  end

  def urls_for_download(style)
    # style: print_image output_files white_image
    case style
    when 'print_image' || 'image'
      [print_image.escaped_url]
    when 'output_files'
      output_files
    when 'white_image'
      [print_image.escaped_url(:gray)]
    else
      []
    end
  end

  def upload_files_collection
    files = download_files_to_upload('print_image') + download_files_to_upload('output_files')
    files += download_files_to_upload('white_image') if product.enable_white?
    files += [back_image_path] if product.enable_back_image?
    files
  end
end
