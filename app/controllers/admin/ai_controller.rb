class Admin::AiController < AdminController
  include WorkFinder

  before_action :find_work_or_archived_work

  def create
    log_with_current_admin @work
    @work.create_activity(:rebuild_ai)
    @work.enqueue_build_ai
    render status: :accepted
  end
end
