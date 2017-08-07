class Admin::UpdateAssetPackageFileForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :small_package, :large_package, :version
  DIRS = %w(colorsticker frame line shape sticker texture typography).freeze
  SMALL_PACKAGE_NAME = 'package.zip'.freeze
  validates :small_package, :large_package, presence: true
  validate :validate_packages

  def initialize(options = {})
    @small_package = options[:small_package]
    @large_package = options[:large_package]
    @version = options.delete(:version)
  end

  def upload
    valid? && upload_package
  end

  private

  # development 默认不会upload
  # 需要的自己打开
  def upload_package
    # return true if Rails.env.development?
    files = [small_package_upload_info] + extract_large_package
    AssetPackage::UploaderService.new(files).execute
  end

  def upload_large_package_file(uploader)
    large_package_file_list.each do |file|
      uploader.store! file
    end
  end

  def validate_packages
    return false unless small_package.present? && large_package.present?
    validate_dirs
    validate_filenames
    validate_filepath
  end

  def validate_dirs
    small_dirs = small_package_filepath_list.map { |path| path.split('/').first }.uniq
    large_dirs = large_package_filepath_list.map { |path| path.split('/').first }.uniq
    error_small_dirs = (small_dirs | DIRS) - small_dirs
    error_large_dirs = (large_dirs | DIRS) - large_dirs

    if error_small_dirs.present?
      errors.add(:small_package, I18n.t('errors.package_dirs_error', dirs: error_small_dirs))
    end

    if error_large_dirs.present?
      errors.add(:large_package, I18n.t('errors.package_dirs_error', dirs: error_large_dirs))
    end
  end

  # 小圖 zip 包需要檢查在資料夾中是否每一個檔案都是 's_' 開頭
  # 並且檔名中不可以含有 @2x、@3x 等字，並且一律為 webP 格式
  def validate_filenames
    error_filenames = []
    small_package_filename_list.all? do |filename|
      error_filenames << filename unless filename =~ /^s_((?!@(\d)x).)*.webp$/
    end
    errors.add(:small_package, I18n.t('errors.package_filename_error', filenames: error_filenames)) if error_filenames.present?
  end

  # 小圖 zip 包與大圖 zip 包內的所有檔名作比對，檔案應該要 1 比 1 相同
  # 就是小圖包裡面的所有檔案列出來去掉開頭的 's_' 后應該會跟大圖包的所有檔名一致
  def validate_filepath
    small_paths = small_package_filepath_list.map { |path| path.sub(%r{/s_}, '/') }
    error_paths = (small_paths | large_package_filepath_list) - large_package_filepath_list
    errors.add(:large_package, I18n.t('errors.package_filepath_error', filepath: error_paths)) if error_paths.present?
  end

  def extract_zip_entries(file, file_type)
    zip_extractor = ZipExtractor.new(file, /^(?!__MACOSX).*\.webp/)
    zip_extractor.extract_zip_entries
  rescue Zip::Error => e
    errors.add(file_type, e.message)
  end

  def extract_small_package
    @extract_small_package ||= extract_zip_entries(small_package, :small_package)
  end

  def extract_large_package
    @extract_large_package ||= extract_zip_entries(large_package, :large_package)
  end

  def small_package_filename_list
    @small_package_filename_list ||= extract_small_package.map { |info| info[:filename] }
  end

  def small_package_filepath_list
    @small_package_filepath_list ||= extract_small_package.map { |info| info[:path] }
  end

  def large_package_filepath_list
    @large_package_filepath_list ||= extract_large_package.map { |info| info[:path] }
  end

  def small_package_file_list
    @small_package_file_list ||= extract_small_package.map { |info| info[:file] }
  end

  def large_package_file_list
    @large_package_file_list ||= extract_large_package.map { |info| info[:file] }
  end

  def small_package_upload_info
    {
      path: SMALL_PACKAGE_NAME,
      file: small_package
    }
  end
end
