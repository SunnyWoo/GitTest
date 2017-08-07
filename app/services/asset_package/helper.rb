module AssetPackage::Helper
  def bucket
    @bucket ||= if Region.china?
                  Settings.asset_package.qiniu.bucket
                else
                  Settings.asset_package.aws_s3.bucket
                end
  end

  def folder
    case Rails.env
    when 'production'
      'prod'
    when 'production_ready'
      'pr'
    when 'staging'
      'stg'
    when 'development'
      'dev'
    else
      'dev'
    end
  end

  def cdn_host
    if Region.china?
      Settings.asset_package.qiniu.cnd_host
    else
      Settings.asset_package.aws_s3.cnd_host
    end
  end

  def file_url(filename)
    [cdn_host, filename].join('/')
  end

  def upload_path(file_info)
    [folder, file_info[:path]].join('/')
  end

  def upload_path_with_last_version(file_info)
    [folder, CpResource.last.version, file_info[:path]].join('/')
  end

  def prefix
    folder + '/'
  end

  def small_package_filename(path)
    path + Admin::UpdateAssetPackageFileForm::SMALL_PACKAGE_NAME
  end
end
