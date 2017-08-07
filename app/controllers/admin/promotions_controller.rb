class Admin::PromotionsController < Admin::ResourcesController
  before_action :find_promotion, except: %w(index new create)

  def index
    q = query_params
    @search = Promotion.ransack(q)
    @promotions = Admin::PromotionDecorator.decorate_collection @search.result.order(created_at: :desc).page(params[:page] || 1)
  end

  def new
    promotion = Promotion.new
    @form = Admin::PromotionForm.new(promotion)
  end

  def create
    promotion = Promotion.new
    @form = Admin::PromotionForm.new(promotion)
    @form.attributes = promotion_creation_params
    if @form.save
      log_with_current_admin(promotion)
      flash[:notice] = "建立完成，請繼續設定活動內容"
      redirect_to edit_admin_promotion_path(promotion)
    else
      render :new
    end
  end

  def edit
    promotion = Promotion.find(params[:id])
    @form = Admin::PromotionForm.new(promotion)
  end

  def update
    promotion = Promotion.find(params[:id])

    @form = Admin::PromotionForm.new(@promotion)
    @form.assign_attributes(promotion_update_params)

    if @form.save
      log_with_current_admin promotion
      flash[:notice] = '更新成功!'
      redirect_to admin_promotion_path(promotion)
    else
      render action: :edit
    end
  end

  def show
    promotion = Promotion.find(params[:id])
    @presenter = Admin::PromotionPresenter.new(promotion)
  end

  def submit
    if @promotion.can_submit?
      if @promotion.submit!
        flash[:notice] = I18n.t('promotions.messages.submit_success')
      else
        flash[:notice] = @promotion.errors.full_messages.join("\n")
      end
    else
      flash[:error] = I18n.t('promotions.messages.submit_fail')
    end
    redirect_to :back
  end

  def destroy
    fail ApplicationError.new('delete fail') unless @promotion.can_delete?
    @promotion.destroy
    redirect_to :back
  end

  def fallback
    order = Order.find_by! uuid: params[:order_uuid]
    if @promotion.adjustments.fallbackable.includes(:order).where(order: order).present?
      @promotion.fallback_the_order(order)
      redirect_to :back, flash: { success: I18n.t('promotions.messages.fallback_success') }
    else
      redirect_to :back, flash: { alert: I18n.t('promotions.messages.fallback_fail') }
    end
  end

  def manual
    order = Order.find_by! uuid: params[:order_uuid]
    if @promotion.manual_the_order(order)
      redirect_to :back, flash: { success: I18n.t('promotions.messages.manual_success') }
    else
      redirect_to :back, flash: { alert: I18n.t('promotions.messages.manual_fail') }
    end
  end

  # Search Works
  def works
    search = StandardizedWork.is_public.ransack(params[:search])
    @works = search.result.page(params[:page]).per_page(30)
  end

  def current_promotion
    find_promotion
  end

  helper_method :current_promotion

  private

  def promotion_creation_params
    params.require(:promotion).permit(:name, :type, :begins_at, :ends_at, :description)
  end

  def promotion_update_params
    params.require(:promotion).permit(
      :name, :begins_at, :ends_at, :unlimited, :description,
      rule_parameters: [:discount_type, :percentage, :price_tier_id],
      product_category_ids: [], product_ids: [],
      promotion_references: promotion_references_params,
      rules: promotion_rules_params
    )
  end

  def promotion_references_params
    Array(params[:promotion][:promotion_references].try(:keys)).map do |key|
      [key.to_sym, [:id, :promotable_type, :promotable_id, :price_tier_id, :_destroy]]
    end.to_h
  end

  def promotion_rules_params
    [
      :id, :condition, :quantity, :threshold_id, :bdevent_id,
      product_model_ids: [], designer_ids: [],
      product_category_ids: [], work_gids: []
    ]
  end

  def find_promotion
    @promotion ||= Promotion.find(params[:id])
  end

  def query_params
    q = Hash(params[:q])
    return q unless q.empty?
    q[:aasm_state_not_in] = Promotion.aasm_states.values_at("stopped", "ended")
    q
  end
end
