class Admin::CampaignsController < AdminController
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]
  before_action :find_feature, only: [:edit]

  def index
    @campaigns = Campaign.page(params[:page]).order('id DESC')
  end

  def new
    @campaign = Campaign.new
    CampaignImage::KEY_LIST.each do |key|
      @campaign.campaign_images.build(key: key)
    end
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_campaigns_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      respond_to do |format|
        format.html { redirect_to admin_campaigns_path }
        format.json { render json: { status: 'ok' } }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render status: 400, json: { status: 'bad' } }
      end
    end
  end

  def destroy
    @campaign.destroy
    redirect_to admin_campaigns_path
  end

  private

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end

  def find_feature
    @features = [@campaign.key].map { |name| feature(name) }
  end

  def campaign_params
    params.require(:campaign).permit(:name, :key, :title, :desc, :designer_username,
      :artworks_class, :about_designer, :aasm_state, wordings: Campaign::WORDING_KEYS.keys,
      campaign_images_attributes: [:campaign_id, :key, :file, :desc, :_destroy, :id, :link, :open_in_new_tab])
  end
end
