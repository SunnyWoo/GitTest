class AssetPackageInvalidationWorker
  include Sidekiq::Worker

  def perform
    if Region.china?
      AssetPackage::QiniuService.new.create_invalidation
    else
      AssetPackage::AwsS3Service.new.create_invalidation
    end
  end
end
