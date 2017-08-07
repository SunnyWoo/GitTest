class Admin::CouponNoticesController < Admin::ResourcesController
  def index
    @search = model_class.ransack(params[:q])
    @resources = @search.result.page(params[:page])
  end

  def new
    super
  end

  def create
    @resource = CouponNotice.new(notice_params)
    if @resource.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    super
  end

  def update
    @resource = CouponNotice.find(params[:id])
    notice_update_params = notice_params
    notice_update_params[:platform] ||= {}
    notice_update_params[:region] ||= {}
    if @resource.update_attributes(notice_update_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def preview
    @china_notices = CouponNotice.china
    @global_notices = CouponNotice.global
  end

  def destroy
    super
  end

  private

  def notice_params
    params.require(:coupon_notice).permit(:coupon_id, :notice, :available,
                                          platform: [:mobile, :email],
                                          region: [:china, :global])
  end
end
