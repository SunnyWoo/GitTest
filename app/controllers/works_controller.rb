class WorksController < ApplicationController
  include Devise::Controllers::Rememberable

  before_action :authenticate_user!, only: %w(edit update)
  before_action :find_work, only: [:edit, :update, :preview, :finish, :destroy]
  before_action :find_work_for_show, only: 'show'
  before_action :set_cache_buster, only: 'edit'
  before_action :set_device_type, only: 'new'

  def index
    @model = ProductModel.customizable_on('website').find_by_name!(params[:model])
    redirect_to shop_path(@model)
  end

  def new
    @categories = ProductCategory.available
    @app_url = deeplink('create')
    set_meta_tags al: {
      ios: {
        url: @app_url,
        app_store_id: 898_632_563,
        app_name: I18n.t('app.name')
      },
      web: {
        url: new_work_url,
        should_fallback: 'true'
      }
    }
  end

  def create
    @model = ProductModel.customizable_on('website').find(params[:model_id])
    @work = Work.new(
      name: 'My Design',
      product: @model,
      work_type: 'is_private',
      user: current_user_or_guest,
      uuid: UUIDTools::UUID.timestamp_create.to_s
    )
    log_with_current_user @work
    @work.save!
    redirect_to edit_work_path(@work)
  end

  def show
    redirect_to shop_index_path, status: :found unless @work.authorize?(current_user) || @work.redeem?
    @same_design = @work.same_design
    impressionist(@work)
    @recommend_works = @work.recommend_works
    title = "#{@work.name} #{@work.product_name}"
    set_meta_tags title: title,
                  description: @work.description,
                  canonical: shop_work_url(@work.product, @work, locale: I18n.locale),
                  reverse: true,
                  og: {
                    title: "#{title} | #{t('site.name')}",
                    description: @work.description,
                    image: Monads::Optional.new(@work.order_image).share.url.value
                  }
  end

  def edit
    render layout: 'editor'
  end

  def update
    log_with_current_user @work
    if @work.update_attributes(work_params)
      render json: @work
    else
      render json: @work.errors, status: :unprocessable_entity
    end
  end

  def preview
  end

  def finish
    log_with_current_user @work
    if @work.finish!
      @work.enqueue_build_print_image
      render json: { status: 'ok', message: 'Save Success!' }
    else
      render json: { status: 'error', message: @work.errors.full_messages }
    end
  end

  def destroy
    if @work.destroy
      render json: { status: 'ok', message: 'Destroy Success!' }
    else
      render json: { status: 'error', message: @work.errors.full_messages }
    end
  end

  def questionnaire
  end

  private

  def current_user_or_guest
    current_user || User.new_guest.tap do |user|
      sign_in user
      remember_me user
    end
  end

  def work_params
    params.require(:work).permit(:name)
  end

  def find_work
    work_id = params[:id] || params[:work_id]
    begin
      @work = current_user.works.find(work_id)
    rescue
      return render_404
    end
  end

  def find_work_for_show
    work_id = params[:work_id] || params[:id]
    @work = StandardizedWork.with_available_product.published.find_id_or_slug(work_id).first || Work.with_available_product.find(work_id)
  end

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma']        = 'no-cache'
    response.headers['Expires']       = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
