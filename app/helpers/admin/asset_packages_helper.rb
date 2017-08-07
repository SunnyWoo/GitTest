module Admin::AssetPackagesHelper
  def render_package_download_info
    list_urls = if Region.china?
                  AssetPackage::QiniuService.new.list_urls
                else
                  AssetPackage::AwsS3Service.new.list_urls
                end
    list_urls = list_urls.map do |url|
      content_tag :p, url
    end
    safe_join(list_urls)
  end
end
