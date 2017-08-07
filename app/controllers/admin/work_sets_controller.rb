class Admin::WorkSetsController < AdminController
  def index
    @work_sets = WorkSet.non_store.page(params[:page]).order('id DESC')
    @work_set ||= WorkSet.new
    @work_set_before ||= WorkSetBefore.new
  end

  def create
    @work_set = WorkSet.new(work_set_params)
    if @work_set.save
      redirect_to admin_work_sets_path
    else
      index
      render :index
    end
  end

  private

  def work_set_params
    params.require(:work_set).permit(:designer_id,
                                     :model_id,
                                     :zip,
                                     :build_previews,
                                     :is_build_print_image,
                                     :aasm_state,
                                     :designer_type)
  end
end
