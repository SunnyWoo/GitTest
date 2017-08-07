class Mobile::RedeemsController < MobileController
  before_action :find_user_from_access_token, only: %w(index)
  before_action :find_event, only: %w(show)
  before_action :find_redeem_work, only: %w(work create mobile_web_check_out)
  before_action :init_order, only: %w(create)
  before_action :check_current_user, only: %w(create)
  before_action :check_mobile_web_check_out, only: %w(mobile_web_check_out)

  def index
    @title = I18n.t('redeem.title')
    @bdevetns = Bdevent.event_available
  end

  def show
    @title = @bdevent.title
  end

  def work
  end

  def success
  end

  def mobile_web_check_out
    coupon = Coupon.find_by! code: session[:redeem_code]
    if coupon.can_use_with_bdevent?(session[:bdevent_id], current_user)
      cart = CartSession.new(controller: self, user_id: current_user.id)
      cart.clean
      cart.add_items(@redeem_work.to_gid, 1)
      cart.apply_coupon_code session[:redeem_code]
      cart.cart.payment = 'redeem'
      cart.cart.bdevent_id = session[:bdevent_id]
      cart.save
      redirect_to view_context.render_cart_index_url(params.slice(:commandp_app))
    else
      render :work
    end
  end

  def check_out
    @shipping_info = ShippingInfo.new
    @work_gid = params[:sgid]
    @title = I18n.t('redeem.shipping_info.title')
  end

  # create需要current_user，而current_user的取得必須先經過index，所以無法不經由兌換流程而直接單獨執行create
  def create
    @order.billing_info.attributes = shipping_info_params
    @order.shipping_info.attributes = shipping_info_params
    coupon = Coupon.find_by! code: session[:redeem_code]
    @order.coupon = coupon
    if coupon.can_use_with_bdevent?(session[:bdevent_id], current_user)
      @order.save!
      @order.payment_object.pay
      clean_bdevent_session
      redirect_to success_mobile_redeems_path
    else
      @work_gid = @redeem_work.to_sgid_param
      @shipping_info = @order.shipping_info
      render :check_out
    end
  end

  protected

  def shipping_info_params
    params.require(:shipping_info).permit(:name, :phone, :address, :state,
                                          :zip_code, :country_code, :email)
          .merge('shipping_way' => 'standard')
  end

  def find_redeem_work
    @redeem_work = GlobalID::Locator.locate_signed(params[:work_gid])
    not_found_error unless @redeem_work
  end

  def find_event
    @bdevent = Bdevent.find(params[:id])
    session[:bdevent_id] = @bdevent.id
  end

  def init_order
    @order = Order.new build_order_params
    @order.build_shipping_info
    @order.build_billing_info
    @order.order_items.build(itemable: @redeem_work, quantity: 1)
    @order.bdevent_id = session[:bdevent_id]
  end

  def build_order_params
    {
      user: current_user,
      payment: 'redeem',
      currency: current_currency_code,
      platform: os_type,
      ip: remote_ip,
      user_agent: request.user_agent,
      locale: I18n.locale
    }
  end

  def find_user_from_access_token
    resource_owner = ResourceOwner.from_access_token(params[:access_token])
    user = resource_owner.try(:user)
    return render_404 unless user
    sign_in user
    session[:access_token] = params[:access_token]
  end

  def check_current_user
    fail ActiveRecord::RecordNotFound unless current_user
  end

  def clean_bdevent_session
    session.delete(:redeem_code)
    session.delete(:bdevent_id)
  end

  def check_mobile_web_check_out
    not_found_error unless feature(:mobile_web_check_out).enable_for_current_session?
  end
end
