class AssetPackage::UploaderService
  include AssetPackage::Helper
  attr_reader :files

  def initialize(files = [])
    files = Array(files) unless files.is_a?(Array)
    @files = files
  end

  def execute
    if Region.china?
      upload_to_qiniu
    else
      upload_to_aws
    end
    AssetPackageInvalidationWorker.perform_async
  end

  private

  def upload_to_qiniu
    files.each do |file|
      qiniu_service.upload(file)
    end
  rescue => e
    Rollbar.error(e) unless Rails.env.development?
    fail ApplicationError, e
  ensure
    files.each { |file| delete_temp_file(file[:file].path) }
  end

  def upload_to_aws
    files.each do |file|
      aws_s3_service.upload(file)
    end
  rescue => e
    Rollbar.error(e) unless Rails.env.development?
    fail ApplicationError, e
  ensure
    files.each { |file| delete_temp_file(file[:file].path) }
  end

  def qiniu_service
    @qiniu_service ||= AssetPackage::QiniuService.new
  end

  def aws_s3_service
    @aws_s3_service ||= AssetPackage::AwsS3Service.new
  end

  def delete_temp_file(path)
    File.delete(path) if File.exist?(path)
  end
end
