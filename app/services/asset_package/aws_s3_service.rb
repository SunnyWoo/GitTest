class AssetPackage::AwsS3Service
  include AssetPackage::Helper
  attr_reader :aws_s3

  def initialize
    # 测试可以打开加上http_wire_trace: true
    @aws_s3 = AWS::S3.new(
      access_key_id: Settings.asset_package.aws_s3.access_key_id,
      secret_access_key: Settings.asset_package.aws_s3.secret_access_key
    )
  end

  # 取得線上檔案列表
  def list_urls(version = nil)
    list_filename(version).map do |filename|
      [Settings.asset_package.aws_s3.cdn_host, filename].join('/')
    end
  end

  # 上传文件到AWS S3
  def upload(file)
    @aws_s3.buckets[bucket].objects[upload_path(file)].write(file: file[:file])
    #upload path with version
    @aws_s3.buckets[bucket].objects[upload_path_with_last_version(file)].write(file: file[:file])
  end

  def create_invalidation
    invalidation_path = ['/', folder, '/*'].join('')
    result = cloud_front_client.create_invalidation(
      distribution_id: Settings.asset_package.aws_s3.distribution_id,
      invalidation_batch: {
        paths: {
          quantity: 1,
          items: [invalidation_path],
        },
        caller_reference: Time.current.to_i.to_s
      }
    )
    unless result.status.in? %w(InProgress Completed)
      fail AssetPackageInvalidationError, result
    end
  end

  # 查看invalidation信息
  def list_invalidations
    cloud_front_client.list_invalidations(distribution_id: Settings.asset_package.aws_s3.distribution_id)
  end

  private

  def client
    @client ||= @aws_s3.client
  end

  def cloud_front_client
    @cloud_front_client ||= AWS::CloudFront::Client.new(
      access_key_id: Settings.asset_package.aws_s3.access_key_id,
      secret_access_key: Settings.asset_package.aws_s3.secret_access_key
    )
  end

  # 获取存取在AWS S3中folder目录下的所有文件名,并排序
  # 小图包名称放在第一位
  def list_filename(version)
    new_prefix = version.present? ? "#{prefix}#{version}/" : prefix
    contents = client.list_objects(bucket_name: bucket, prefix: new_prefix, max_keys: 1000).contents
    return [] if contents.empty?
    list_filename = contents.map(&:key).sort
    small_package_name = list_filename.delete(small_package_filename(new_prefix))
    list_filename.insert(0, small_package_name)
  end
end
