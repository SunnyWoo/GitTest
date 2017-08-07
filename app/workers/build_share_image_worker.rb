class BuildShareImageWorker
  include Sidekiq::Worker

  def perform(work_gid)
    work = GlobalID::Locator.locate(work_gid)
    work.build_share_image
  end
end
