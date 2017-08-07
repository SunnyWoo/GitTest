class Admin::OrderImagesController < AdminController
  include WorkFinder

  before_action :find_work_or_archived_work

  def create
    log_with_current_admin @work
    @work.create_activity(:rebuild_order_image)
    @job = @work.enqueue_build_previews_by_print_image
    render status: :accepted
  end
end
