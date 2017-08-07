class Admin::EmailBannersController < AdminController
  before_action :find_email_banner, only: [:show, :edit, :update, :destroy]

  def index
    @search = EmailBanner.ransack(params[:q])
    @email_banners = @search.result.page(params[:page]).order('created_at DESC')
  end

  def show
  end

  def new
    @email_banner = EmailBanner.new
  end

  def create
    @email_banner = EmailBanner.new(admin_permitted_params.email_banner)
    if @email_banner.save
      flash[:notice] = 'Create Success!'
      redirect_to admin_email_banners_path
    else
      flash[:error] = @email_banner.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @email_banner.update(admin_permitted_params.email_banner)
      redirect_to admin_email_banners_path
    else
      render :edit
    end
  end

  def destroy
    @email_banner.destroy
    redirect_to admin_email_banners_path
  end

  private

  def find_email_banner
    @email_banner = EmailBanner.find(params[:id]) if params[:id]
  end
end
