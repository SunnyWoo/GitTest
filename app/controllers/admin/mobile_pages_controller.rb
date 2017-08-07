class Admin::MobilePagesController < AdminController
  before_action :find_mobile_page, only: [:show, :edit, :update, :preview, :preview_by_device]
  before_action :find_country_code, only: :index

  def index
    @search = MobilePage.ransack(params[:q])
    @mobile_pages = @search.result.where(country_code: @country_code).page(params[:page]).order('id DESC')
    respond_to do |f|
      f.html
      f.json
    end
  end

  def new
    @mobile_page = MobilePage.new
    @mobile_page.country_code ||= params[:country_code].upcase
  end

  def create
    @mobile_page = MobilePage.new(mobile_page_params)
    if @mobile_page.save
      redirect_to edit_admin_mobile_page_path(@mobile_page)
    else
      flash[:error] = @mobile_page.errors.full_messages
      render :new
    end
  end

  def show
    respond_to do |f|
      f.json { render 'api/v3/mobile_pages/show' }
    end
  end

  def edit
  end

  def update
    if @mobile_page.update(mobile_page_params)
      redirect_to admin_mobile_pages_path(country_code: @mobile_page.country_code)
    else
      flash[:error] = @mobile_page.errors.full_messages
      render :edit
    end
  end

  def preview
    mobile_page_preview = @mobile_page.mobile_page_preview
    if mobile_page_preview.blank?
      attributes = @mobile_page.attributes.delete_if { |key| key.in? %w(id) }
      mobile_page_preview = @mobile_page.build_mobile_page_preview(attributes)
    end
    mobile_page_preview.attributes = mobile_page_params
    mobile_page_preview.save!
    respond_to do |f|
      f.json { render json: { status: 'success' } }
    end
  end

  def preview_by_device
    set_preview_parmas
  end

  private

  def find_mobile_page
    @mobile_page = MobilePage.find(params[:id])
  end

  def mobile_page_params
    params.require(:mobile_page).permit(:begin_at, :close_at, :key, :title, :page_type, :country_code, :is_enabled)
  end

  def find_country_code
    @country_code = params[:country_code] || MobilePage::COUNTRY_CODES.first
  end

  def set_preview_parmas
    key = @mobile_page.key
    env = Rails.env.camelize(:lower)
    region = Region.region

    if params[:device] =~ /^iphone/
      preview_params = { params: { key: key, env: env, region: region } }.to_json
      @preview_key = SiteSetting.by_key('iphone_preview_key')
    else
      value = [[:key, key], [:env, env], [:region, region]].map do |p|
        p.join('=')
      end.join('|')
      preview_params = { params: value }.to_json
      @preview_key = SiteSetting.by_key('android_preview_key')
    end

    @preview_parmas = ERB::Util.url_encode(preview_params)
  end
end
