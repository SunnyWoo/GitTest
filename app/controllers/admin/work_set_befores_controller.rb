class Admin::WorkSetBeforesController < AdminController
  def create
    @work_set = WorkSetBefore.new(work_set_params)
    if @work_set.save
      redirect_to admin_work_sets_path
    else
      flash[:error] = @work_set.errors.full_messages
      redirect_to admin_work_sets_path
    end
  end

  private

  def work_set_params
    params.require(:work_set_before).permit(:designer_id, :model_id, :zip, :work_type)
  end
end
