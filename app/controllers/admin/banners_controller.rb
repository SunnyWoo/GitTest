class Admin::BannersController < AdminController
  def index
    @banners = Banner.ordered.page(params[:page])
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to admin_banners_path
    else
      render :new, flash: { error: @banner.errors.full_messages }
    end
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def update
    @banner = Banner.find(params[:id])
    if @banner.update(banner_params)
      redirect_to admin_banners_path
    else
      render :new, flash: { error: @banner.errors.full_messages }
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to admin_banners_path
  end

  private

  def banner_params
    params.require(:banner).permit(:name, :deeplink, :image,
                                   :begin_on, :end_on, :url,
                                   countries: [], platforms: [])
  end
end
