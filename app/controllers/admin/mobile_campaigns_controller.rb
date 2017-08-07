class Admin::MobileCampaignsController < AdminController
  before_action :find_mobile_campaign, only: [:show, :edit, :update, :destroy, :update_position]

  def index
    # 前端頁面需要使用勿刪
    @per_page = 30
    @mobile_campaigns = MobileCampaign.page(params[:page]).per_page(@per_page)
  end

  def new
    @mobile_campaign = MobileCampaign.new
    I18n.available_locales.each do |locale|
      @mobile_campaign.translations.build(locale: locale)
    end
  end

  def create
    @mobile_campaign = MobileCampaign.new(mobile_campaign_params)
    if @mobile_campaign.save
      redirect_to admin_mobile_campaigns_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @mobile_campaign.update(mobile_campaign_params)
      redirect_to admin_mobile_campaigns_path
    else
      render :edit
    end
  end

  def update_position
    if @mobile_campaign.set_list_position(params[:position])
      render json: { status: 'ok', message: 'Update Success!' }
    else
      render json: { status: 'error', message: @mobile_campaign.errors.full_messages }
    end
  end

  def destroy
    @mobile_campaign.destroy
    redirect_to admin_mobile_campaigns_path
  end

  private

  def find_mobile_campaign
    @mobile_campaign = MobileCampaign.find(params[:id])
  end

  def mobile_campaign_params
    params.require(:mobile_campaign).permit(:campaign_type, :publish_at, :starts_at, :ends_at, :is_enabled,
                                            translations_attributes: [:id, :locale, :kv, :ticker, :title, :desc_short])
  end
end
