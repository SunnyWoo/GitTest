class CartCouponsController < ApplicationController
  # skip_after_action :verify_authorized, except: :index
  # skip_after_action :verify_policy_scoped, only: :index

  before_action :init_cart

  def create
    coupon_code = params[:coupon_code].upcase
    if @cart.valid_coupon_code?(coupon_code, current_user)
      @cart.apply_coupon_code(coupon_code)
      @cart.save
      @coupon_notice = 'Verify successful !'
    else
      @coupon_error = @cart.coupon.errors.full_messages.join(',') if @cart.coupon.try(:errors).present?
      @coupon_error = 'Please enter a vaild coupon code' if @coupon_error.blank?
    end

    respond_to do |format|
      format.js do
        build_tmp_order
        render 'cart/check_out_update'
      end
      format.json do
        render json: { status: (@coupon_notice ? 0 : 1), message: @coupon_notice || @coupon_error }
      end
    end
  end

  def destroy
    @cart.clear_coupon_code
    build_tmp_order

    respond_to do |format|
      format.js do
        render 'cart/check_out_update'
      end
    end
  end

  private

  def init_cart
    sign_in_guest unless user_signed_in?
    @cart = CartSession.new(controller: self, user_id: current_user.id)
  end

  def sign_in_guest
    user = User.new_guest
    sign_in user
  end

  def build_tmp_order
    @cart.save
    @order = @cart.build_tmp_order
    @order = OrderDecorator.new(@order)
  end
end
