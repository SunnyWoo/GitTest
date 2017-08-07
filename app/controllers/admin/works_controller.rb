class Admin::WorksController < Admin::ResourcesController
  include TagCreator

  def index
    @search = model_class.includes(:user,
                                   :attached_cover_image,
                                   :price_tier,
                                   :work_code,
                                   product: [:translations, category: :translations]).ransack(params[:q])
    if params[:deleted].to_b
      @resources = @search.result.deleted
    else
      @resources = @search.result.order('created_at DESC')
    end
    @resources = @resources.page(params[:page]) unless params[:page] == 'all'

    respond_to do |f|
      f.html
      f.json { @works = @resources }
    end
  end

  def search
    @works = Work.search_by_elasticsearch(params[:q], params[:page])
    @works = @works.redeem if params[:redeem].present?
    @query = params[:q]
    render :index
  end

  def new
    super
    @work = Work.new
  end

  def create
    set_tag_ids(:work)
    @work = Work.new(work_params)
    @work.user = Designer.find(params[:work][:user_id])
    log_with_current_admin @work
    @work.save!
    @work.update(remote_cover_image_url: @work.print_image.url)
    @work.build_layer(image: @work.print_image)
    @work.finish!
    @work.reload
    redirect_to collection_path
    @work.enqueue_build_previews_by_print_image
  rescue ActiveRecord::RecordInvalid
    render action: :new
  end

  def show
    if params[:deleted].to_b
      @resource = model_class.with_deleted.find(params[:id])
    else
      @resource = model_class.find(params[:id])
    end
    respond_to do |f|
      f.html
      f.json { @work = @resource }
    end
  end

  def edit
    super
    @form = PlainWorkForm.new(work: @resource)
  end

  # To Do 勢必要 Refactor
  def update
    set_tag_ids(:work)
    @resource = model_class.find(params[:id])
    log_with_current_admin @resource
    if @resource.update_attributes(work_params)
      @resource.update(remote_cover_image_url: @resource.print_image.url)
      @resource.build_layer(image: @resource.print_image)
      flash[:notice] = "#{model_name} (#{@resource.class.primary_key} = #{@resource.to_param}) 更新成功! 製圖/縮圖需要時間, 請稍後... url: #{@resource.cover_image.url}"
      redirect_to action: :edit
      @resource.enqueue_build_previews_by_print_image
    else
      render :edit
    end
  end

  def history
    @work = Work.find(params[:work_id])
    @versions = PaperTrail::Version
                .where('(item_type = ? AND item_id = ? ) OR (item_type = ? AND item_id in (?)) ', 'Work', @work.id, 'Layer', @work.layers.map(&:id))
                .order('id DESC')
                .page(params[:page])
  end

  def refresh
    @work = Work.find(params[:id])
    @work.touch
    @work.create_activity(:refresh_thumbnails)
    render nothing: true
  end

  def restore
    Work.restore(params[:id])
    redirect_to :back
  end

  private

  def crop_params
    params.require(:work).permit(:crop_x, :crop_y, :crop_h, :crop_w)
  end

  def work_params
    params.require(:work).permit(:slug, :name, :description, :spec_id, :model_id,
                                 :print_image, :work_type, :featured,
                                 :price_tier_id, :user_type,
                                 :user_id, tag_ids: [])
  end
end
