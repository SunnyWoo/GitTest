class Admin::StandardizedWorksController < AdminController
  include TagCreator

  def index
    q = params[:q] || {}
    q['s'] = 'id desc' unless q[:s].present?
    @search = StandardizedWork.non_store.ransack(q)
    @works = @search.result.includes(:previews).page(params[:page])
  end

  def search
    @works = StandardizedWork.non_store.search_by_elasticsearch(params[:q], params[:page])
    render :index
  end

  def new
    @work = StandardizedWork.new
    respond_to do |f|
      f.html
      f.json { render 'api/v3/standardized_works/show' }
    end
  end

  def create
    set_tag_ids(:work)
    @work = StandardizedWork.new(work_params)
    if @work.save
      render 'api/v3/standardized_works/show'
    else
      render json: @work.errors, status: :unprocessable_entity
    end
  end

  def show
    edit
    respond_to do |f|
      f.html { render 'admin/standardized_works/edit' }
      f.json { render 'api/v3/standardized_works/show' }
    end
  end

  def edit
    @work = StandardizedWork.find(params[:id])
  end

  def update
    set_tag_ids(:work)
    @work = StandardizedWork.find(params[:id])
    if @work.update(work_params)
      respond_to do |f|
        f.js { render 'update_list_item' }
        f.json { render 'api/v3/standardized_works/show' }
      end
    else
      render json: @work.errors, status: :unprocessable_entity
    end
  end

  def publish
    @work = StandardizedWork.find(params[:id])
    @work.publish!
    render 'update_list_item'
  end

  def pull
    @work = StandardizedWork.find(params[:id])
    @work.pull!
    render 'update_list_item'
  end

  private

  def work_params
    params.require(:work).permit(
      :model_id, :user_id, :user_type, :name, :is_build_print_image,
      :price_tier_id, :featured, :print_image_aid, :build_previews,
      tag_ids: [],
      previews_attributes: [:id, :key, :image_aid, :position, :_destroy],
      output_files_attributes: [:id, :key, :file_aid, :_destroy]
    )
  end
end
