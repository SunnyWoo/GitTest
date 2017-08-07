class CartController < ApplicationController
  # skip_after_action :verify_authorized, except: :index
  # skip_after_action :verify_policy_scoped, only: :index

  before_action :init_order
  before_action :find_work, only: [:add, :update, :destroy]
  before_action :set_device_type
  after_action :save_cart, only: %w(create add update destroy payment)
  respond_to :js, only: [:add, :update, :destroy]

  def index
    cart_list
    respond_to do |format|
      format.html do
        render layout: 'cart' if browser.mobile?
      end
      format.json
    end
  end

  def add
    if @work.class.name == 'Work'
      @work.finish! unless @work.finished
      @work = @work.create_archive unless @work.archived?
    end

    @cart.add_items(@work.to_gid, params[:q])
    respond_to do |format|
      format.html { redirect_to cart_index_path }
      format.js do
        cart_list
        render 'index'
      end
    end
  end

  def update
    @cart.update_items(@work.to_gid, params[:q])
    respond_to do |format|
      format.html { redirect_to cart_index_path }
      format.js do
        cart_list
        render 'index'
      end
    end
  end

  def destroy
    @cart.delete_items(@work.to_gid)
    @cart.delete_items(@work.uuid) # FIXME: for backward compatibility
    respond_to do |format|
      format.js do
        cart_list
        render 'index'
      end
    end
  end

  def check_out
    flash[:coupon_error] = nil
    # 20151202: 要求拿掉 express 快速運送
    @shipping_way_list = ShippingInfo.shipping_ways.slice(:standard, :cash_on_delivery)
    cart_list
    redirect_to root_path if @order.order_items.size == 0
  end

  def check_out_update
    if params[:attr].present?
      att = params[:attr]
      args = { att.to_sym => params[:val] }
      args = { shipping_info: { country_code: params[:val] } } if att.match(/country_code/)
      @cart.update_check_out(args)
    end
    respond_to do |format|
      format.js do
        cart_list
      end
    end
  end

  def create
    @cart.update_check_out(order_params)
    redirect_to summary_cart_index_path
  end

  def summary
    cart_list
    redirect_to root_path if @order.order_items.size == 0
  end

  def payment
    @order = @cart.build_order
    log_with_current_user @order

    if @order.save
      @order.payment_object.webpay(self)
      @cart.clean(@order)
    else
      render json: { status: 'error', message: @order.errors.full_messages }, status: :bad_request
    end
  end

  private

  def cart_list
    save_cart
    @cart = CartSession.new(controller: self, user_id: current_user.id)
    # coupon不可以使用时会fail，购物车页面打不开，先清除coupon
    begin
      @order = @cart.build_tmp_order
    rescue CannotUseCouponError
      @cart.clear_coupon_code
      @order = @cart.build_tmp_order
    end
    @order = OrderDecorator.new(@order)
  end

  def save_cart
    @cart.save
  end

  def init_order
    sign_in_guest unless user_signed_in?
    @cart = CartSession.new(controller: self, user_id: current_user.id)
  end

  def find_work
    @work = StandardizedWork.with_available_product.find_by(uuid: params[:id]) ||
            Work.with_available_product.find_by(uuid: params[:id]) ||
            ArchivedWork.find_by(uuid: params[:id]) ||
            ArchivedStandardizedWork.find_by!(uuid: params[:id])
  end

  def order_params
    params.require(:order).permit(:payment, billing_info: billing_profiles_attrs, shipping_info: billing_profiles_attrs)
  end

  def shipping_info_params
    params.require(:shipping_info).permit(billing_profiles_attrs)
  end

  def billing_info_params
    params.require(:billing_info).permit(billing_profiles_attrs)
  end

  def billing_profiles_attrs
    [:name, :phone, :address, :city, :state, :zip_code, :country, :country_code, :shipping_way, :email]
  end

  def sign_in_guest
    user = User.new_guest
    sign_in user
  end
end
