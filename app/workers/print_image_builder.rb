class PrintImageBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :print_images

  def perform(work_gid)
    @work = GlobalID::Locator.locate(work_gid)
    @work.logcraft_source = {channel: 'worker'}
    @work.create_activity('begin_build_print_image')
    @work.build_print_image
    @work.create_activity('end_build_print_image', url: @work.print_image.url )
  end
end
