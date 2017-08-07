class UsersController < ApplicationController
  before_action :check_signed_in, only: [:profile, :address, :order_history]

  def upload_avatar
    if user_signed_in?
      current_user.avatar = params[:user_avatar]
      if current_user.save!
        render json: { status: 'ok', file: params[:user_avatar],
          url: { s154: current_user.avatar.url(:s154), s35: current_user.avatar.url(:s35) } }
      end
    end
  end

  def update
    if current_user.update_attributes(permitted_params.user)
      flash[:notice] = 'Update Profile Ok';
    else
      flash[:error] = 'Update Profile Error';
    end
    redirect_to profile_users_path
  end

  def profile
  end

  def address
    @address_infos = current_user.address_infos
  end

  def order_history
    @orders = current_user.orders.viewable.order("id DESC")
  end

  def order
    if user_signed_in?
      @order = current_user.orders.viewable.includes(:order_items).find_by(order_no: params[:order_no])
    elsif session[:guest_user_order_no] == params[:order_no]
      @order = Order.includes(:order_items).find_by(order_no: params[:order_no])
    end
    render_404 if @order.nil?
    @order = OrderDecorator.new(@order)
    # @expired_at = (@order.payment_info['expired_at'] != nil) ? l DateTime.parse(@order.payment_info['expired_at']), format: :short : ''
  end

  def works
    if user_signed_in?
      if current_user.email == 'guest_a6b59a62-5dc6-11e5-8604-0a9822c75273@commandp.me'
        @works = current_user.works.page(params[:page]).per_page(17)
      else
        @works = current_user.works.finished.page(params[:page]).per_page(17)
      end
    else
      redirect_to root_path
    end
  end

  def check_signed_in
    if !user_signed_in?
      store_location
      redirect_to user_omniauth_authorize_path(:facebook)
    end
  end
end
