class B2bStickerService
  attr_reader :excel_path, :excel_extension, :zip_path, :email

  def initialize(args = {})
    args = args.symbolize_keys
    @excel_path = args.fetch(:excel_path)
    @excel_extension = args.fetch(:excel_extension)
    @zip_path = args.fetch(:zip_path, nil)
    @email = args.fetch(:email)
    make_file_dir
  end

  def execute
    generate

    B2bMailer.stickers(email, zip_output).deliver

    delete_dir
  rescue ExtractImageError, DownloadPdfError => e
    ApplicationMailer.delay.notice_admin(email, 'B2B贴纸', e.message)
  end

  private

  def generate
    extract_images(zip_path)

    @data ||= Roo::Spreadsheet.open(excel_path, extension: excel_extension)
    sheet = @data.sheet(0)
    keys = sheet.row(1)[0..5]
    (2..sheet.last_row).each do |row_index|
      message = Hash[[keys, sheet.row(row_index)[0..5]].transpose]
      download_pdf(message)
    end

    ZipFileGenerator.new(@stickers_dir, zip_output).write
  end

  def zip_output
    "tmp/stickers/#{@current_time}.zip"
  end

  def make_file_dir
    @current_time ||= Time.now.to_i
    @stickers_dir ||= "tmp/stickers/#{@current_time}"
    FileUtils.mkdir_p(@stickers_dir) unless File.directory?(@stickers_dir)
  end

  def delete_dir
    FileUtils.rm_rf(@stickers_dir) if File.directory?(@stickers_dir)
    FileUtils.rm_rf(zip_output) if File.exist?(zip_output)
  end

  def download_pdf(message)
    url = Settings.b2b_sticker_url
    id = message.delete('id')
    params = { image: @images[id].try(:path), message: message }
    res = HTTParty.get(url, query: params)
    fail DownloadPdfError, '下载pdf时发生错误' if res.code != 200
    File.open("#{@stickers_dir}/#{id || Time.now.to_f}.pdf", 'wb') do |file|
      file.write res.body
    end
  end

  def extract_images(zip_path)
    @images = {}
    return unless zip_path
    zip = ZipExtractor.new(File.open(zip_path), /^(?!__MACOSX).*\.(jpg|png)/)
    zip_entries = zip.extract_zip_entries
    @images = zip_entries.each_with_object({}) do |value, hash|
      hash[value[:name]] = value[:file]
    end
  rescue Zip::Error => e
    Rollbar.error(e) unless Rails.env.development?
    fail ExtractImageError, '解压图片时错误'
  end

  class ExtractImageError < StandardError; end
  class DownloadPdfError < StandardError; end
end
