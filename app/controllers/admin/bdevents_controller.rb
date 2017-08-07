class Admin::BdeventsController < AdminController
  before_action :find_bdevent, only: [:show, :edit, :update, :destroy]
  before_action :find_event_type, except: [:edit, :update]
  before_action :find_product_models, only: [:new, :create, :edit, :update]

  def index
    @bdevents = Bdevent.where(event_type: Bdevent.event_types[@event_type]).order('created_at DESC').page(params[:page])
    application_id = Doorkeeper::Application.first.id
    @access_token = Doorkeeper::AccessToken.find_or_create_by(application_id: application_id,
                                                              resource_owner_id: User.guest.first.id).token
  end

  def show
  end

  def new
    @bdevent = Bdevent.new
    @bdevent.event_type = @event_type
    @bdevent.build_bdevent_redeem
    I18n.available_locales.each do |locale|
      @bdevent.translations.build(locale: locale)
      @bdevent.bdevent_images.build(locale: locale)
    end
  end

  def create
    @bdevent = Bdevent.new(bdevent_params)
    if @bdevent.save
      redirect_to admin_bdevents_path(event_type: @bdevent.event_type)
    else
      flash[:error] = @bdevent.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @bdevent.update(bdevent_params)
      redirect_to admin_bdevents_path(event_type: @bdevent.event_type)
    else
      flash[:error] = @bdevent.errors.full_messages
      render :edit
    end
  end

  def destroy
    @bdevent.destroy
    redirect_to admin_bdevents_path(event_type: @event_type)
  end

  def update_flex
    if params[:flex].in? Bdevent::FLEX_TYPES.values
      Bdevent.flex = params[:flex]
      render json: { message: 'Success!' }, status: :ok
    else
      render json: { message: 'Invalid flex type value' }, status: :bad_request
    end
  end

  private

  def find_bdevent
    @bdevent = Bdevent.find(params[:id])
  end

  def find_event_type
    @event_type = params[:event_type] if params[:event_type].present?
    @event_type = 'event' unless Bdevent::EVENT_TYPES.include?(@event_type)
    @event_type
  end

  def bdevent_params
    if params[:bdevent][:bdevent_redeem_attributes]
      params[:bdevent][:bdevent_redeem_attributes][:product_model_ids].try { |i| i.reject!(&:empty?) }
      params[:bdevent][:bdevent_redeem_attributes][:work_ids].try { |i| i.reject!(&:empty?) }
    end
    params.require(:bdevent).permit(:starts_at, :ends_at, :priority, :event_type, :is_enabled, :background,
                                    translations_attributes:[:id, :title, :desc, :banner, :locale, :coming_soon_image,
                                                             :ticker, :coupon_desc],
                                    bdevent_images_attributes: [:bdevent_id, :locale, :file, :_destroy, :id],
                                    bdevent_redeem_attributes: [:bdevent_id, :quantity, :code, :usage_count_limit, :id,
                                                                product_model_ids: [], work_ids: []],
                                    bdevent_works_attributes: [:bdevent_id, :work_id, :image, :title, :position, :id,
                                                               :work_type, :_destroy],
                                    bdevent_products_attributes: [:bdevent_id, :product_id, :image, :title, :position,
                                                                  :id, :_destroy])
  end

  def find_product_models
    @product_models = ProductModel.all.includes(:translations).map { |p| [p.name, p.id] }
  end
end
