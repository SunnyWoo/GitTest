class Admin::FixedImagesController < AdminController
  before_action :find_work

  def destroy
    log_with_current_admin @work
    @work.create_activity(:remove_fixed_image)
    @work.update(remove_fixed_image: true)
    render status: :accepted
  end

  private

  def find_work
    @work = ArchivedWork.find(params[:archived_work_id])
  end
end
