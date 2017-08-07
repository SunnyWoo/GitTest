class Admin::ArchivedWorksController < AdminController
  def index
    @search = ArchivedWork.includes(:layers).order('created_at DESC').ransack(params[:q])
    @works = @search.result.page(params[:page])
  end

  def show
    @work = ArchivedWork.find(params[:id])
    @order_items = @work.order_items
  end

  def edit
    @work = ArchivedWork.find(params[:id])
  end

  def update
    @work = ArchivedWork.find(params[:id])
    log_with_current_admin @work
    if params[:archived_work] && @work.update(work_params)
      redirect_to action: :edit
    else
      render :edit
    end
  end

  def recopy_layers
    @work = ArchivedWork.find(params[:id])
    log_with_current_admin @work
    @work.layers.destroy_all
    @work.update(layers_attributes: @work.original_work.layers.map(&:archived_attributes))
    redirect_to action: :show
  end

  private

  def work_params
    params.require(:archived_work).permit(:fixed_image)
  end
end
