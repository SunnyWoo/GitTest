class Store::Backend::StandardizedWorksController < Store::BackendController
  before_action :find_standardized_work, only: %i(edit update publish pull)

  def index
    @standardized_works = current_store.standardized_works.order(created_at: :desc).page(params[:page]).per_page(30)
  end

  def new
    @work_set ||= WorkSet.new
  end

  def work_set
    @work_set = WorkSet.new designer: current_store
    if @work_set.update work_set_params
      @work_set.works.update_all cradle: StandardizedWork.cradles[:b2b2c]
      redirect_to store_backend_standardized_works_path, flash: { success: I18n.t('store.shared.create_success') }
    else
      flash[:error] = @work_set.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @standardized_work.update(store_permitted_params.standardized_work)
      respond_to do |f|
        f.html { redirect_to store_backend_standardized_works_path, flash: { success: I18n.t('store.shared.update_success') } }
        f.js { render 'update_list_item' }
        f.json { render 'api/v3/standardized_works/show' }
      end
    else
      respond_to do |f|
        f.json { render json: @standardized_work.errors, status: :unprocessable_entity }
        f.html do
          flash[:error] = @standardized_work.errors.full_messages
          render :edit
        end
      end
    end
  end

  def publish
    @standardized_work.publish!
    render 'update_list_item'
  end

  def pull
    @standardized_work.pull!
    render 'update_list_item'
  end

  protected

  def work_set_params
    params.require(:work_set).permit(:model_id,
                                     :zip,
                                     :build_previews,
                                     :is_build_print_image,
                                     :aasm_state)
  end

  def find_standardized_work
    @standardized_work = StandardizedWork.find(params[:id])
  end
end
