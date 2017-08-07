class RedeemsController < ApplicationController
  before_action :set_default_response_format, only: %i(create verify)
  before_action :find_redeem_work, only: [:new, :create]
  before_action :find_coupon, only: [:create, :verify]
  before_action :init_redeem_order

  def new
    not_found_error unless @redeem_work.try(:redeem?).to_b
  end

  def create
    @order.billing_info.attributes = shipping_info_params
    @order.shipping_info.attributes = shipping_info_params
    @order.coupon = @coupon
    if @coupon.can_use_with_redeem_work?(@redeem_work.to_gid_param, current_user)
      @order.save!
      @order.payment_object.pay
      clean_redeem_session
      render json: { status: true, order_no: @order.order_no }
    else
      render json: { status: false, error: @order.errors.full_messages.join(', ') }
    end
  end

  def verify
    res = if @coupon && params[:gid].present?
            verify_redeem_work
          elsif @coupon && params[:bdevent_id].present?
            @coupon.can_use_with_bdevent?(params[:bdevent_id], current_user)
          else
            false
          end
    session[:redeem_code] = @coupon.code if res == true
    render json: { status: res, message: @coupon.errors.full_messages }
  end

  private

  def find_coupon
    @coupon = Coupon.find_by(code: params[:redeem_code].strip.upcase) if params[:redeem_code].present?
    not_found_error unless @coupon
  end

  def find_redeem_work
    @redeem_work = GlobalID::Locator.locate_signed(params[:gid])
    not_found_error unless @redeem_work
  end

  def init_redeem_order
    sign_in_guest unless user_signed_in?
    @order = Order.new(build_order_params)
    @order.build_shipping_info
    @order.build_billing_info
    @order.order_items.build(itemable: @redeem_work, quantity: 1)
  end

  def build_order_params
    order_params = {
      user: current_user,
      payment: 'redeem',
      currency: current_currency_code,
      platform: os_type,
      ip: remote_ip,
      user_agent: request.user_agent,
      locale: I18n.locale
    }
  end

  def shipping_info_params
    params.require(:shipping_info).permit(:name, :phone, :address, :city, :state, :zip_code, :country, :country_code,
                                          :shipping_way, :email)
  end

  def sign_in_guest
    user = User.new_guest
    sign_in user
  end

  def verify_redeem_work
    find_redeem_work
    @coupon.can_use_with_redeem_work?(@redeem_work.to_gid_param, current_user) ||
    @coupon.can_use_with_the_product?(@redeem_work.product.id, current_user)
  end

  def clean_redeem_session
    session.delete(:redeem_code)
  end

  def set_default_response_format
    request.format = :json
  end
end
