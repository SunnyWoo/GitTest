class Admin::PromotionReferencesController < AdminController
  before_action :find_promotion

  def new
    work = GlobalID::Locator.locate(params[:gid])

    if current_promotion.has_included?(work)
      respond_to do |format|
        message = I18n.t('promotion_reference.error.had_been_included')
        format.js { render js: "alert('#{message})" }
        format.html { redirect_to :back, notice: message }
      end
    else
      @reference = current_promotion.references.new(promotable: work)
      @reference.price_tier = work.price_tier || work.product.price_tier if work.respond_to?(:price_tier)
    end
  end

  def current_promotion
    find_promotion
  end

  helper_method :current_promotion

  private

  def find_promotion
    @promotion ||= Promotion::ForItemablePrice.find(params[:promotion_id])
  end
end
