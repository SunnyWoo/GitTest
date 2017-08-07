class AssetPackage::QiniuService
  include AssetPackage::Helper
  REFRESH_URL = 'http://fusion.qiniuapi.com/v2/tune/refresh'.freeze
  attr_reader :qiniu

  def initialize
    # 测试可以打开加上http_wire_trace: true
    Qiniu.establish_connection!(
      access_key: Settings.asset_package.qiniu.access_key_id,
      secret_key: Settings.asset_package.qiniu.secret_access_key
    )
  end

  def upload(file)
    [upload_path(file), upload_path_with_last_version(file)].each do |filename|
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(upload_token(filename), file[:file].path, filename, nil, bucket: bucket)
      unless code == 200
        message = "code: #{code};result: #{result};response_headers: #{response_headers}"
        Rollbar.error(message) unless Rails.env.development?
      end
    end
  end

  def list_urls(version)
    list_filename(version).map do |filename|
      [Settings.asset_package.qiniu.cdn_host, filename].join('/')
    end
  end

  # http://developer.qiniu.com/article/fusion/api/refresh.html
  def create_invalidation
    folder_url = [Settings.asset_package.qiniu.cdn_host, folder, ''].join('/')
    header = { 'Authorization' => "QBox #{manage_token(REFRESH_URL)}", 'Content-Type' => 'application/json' }
    result = RestClient.post REFRESH_URL, { dirs: [folder_url] }.to_json, header
    unless JSON.parse(result)['code'] == 200
      fail AssetPackageInvalidationError, result
    end
  end

  private

  def upload_token(filename)
    # PutPolicy
    # filename:最终资源名,可省略,即缺省为“创建”语义,设置为nil为普通上传,不会覆盖已有文件
    put_policy = Qiniu::Auth::PutPolicy.new(bucket, filename, 3600)
    Qiniu::Auth.generate_uptoken(put_policy)
  end

  def manage_token(url)
    Qiniu::Auth.generate_acctoken(url)
  end

  def list_filename(version)
    new_prefix = version.present? ? "#{prefix}#{version}/" : prefix
    code, result, _response_headers, _s, _d = Qiniu::Storage.list(Qiniu::Storage::ListPolicy.new(bucket, 1000, new_prefix, ''))
    if code == 200
      list_filename = result['items'].map { |item| item['key'] }
      small_package_name = list_filename.delete(small_package_filename(new_prefix))
      list_filename.insert(0, small_package_name)
    else
      Rollbar.error(result) unless Rails.env.development?
    end
  end
end
