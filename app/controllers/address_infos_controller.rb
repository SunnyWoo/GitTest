class AddressInfosController < ApplicationController
  REDIRECT_PATH_REG = %r{^/[a-zA-Z\-]+/(cart/check_out|users/address)+$}i

  before_action :find_address, only: [:edit, :update, :destroy]
  before_action :find_redirect_to, only: [:create, :update, :destroy]

  def show
  end

  def new
    @id = params[:id]
    @page = params[:page]
    @address_info = current_user.address_infos.new
  end

  def create
    address_info = current_user.address_infos.build(update_params)
    if address_info.save
      flash[:notice] = 'Create Address Info Success'
    else
      flash[:error] = address_info.errors.full_messages
    end
    redirect_to @redirect_to
  end

  def edit
    @page = params[:page]
  end

  def update
    if @address_info.update_attributes(update_params)
      flash[:notice] = 'Update Address Info Success'
    else
      flash[:error] = @address_info.errors.full_messages
      flash[:error] = @address_info.to_json
    end
    redirect_to @redirect_to
  end

  def destroy
    @address_info.destroy
    redirect_to_path = params[:r].present? ? params[:r] : check_out_cart_index_path
    redirect_to redirect_to_path
  end

  private

  def find_address
    @address_info = current_user.address_infos.find(params[:id])
  end

  def update_params
    params.require(:address_info).permit(:name, :phone, :address, :city, :state,
                                         :zip_code, :country, :country_code,
                                         :address_name, :email)
  end

  def find_redirect_to
    redirect_to_path = params[:redirect_to] || params[:r] || ''
    @redirect_to = redirect_to_path.match(REDIRECT_PATH_REG) ? redirect_to_path : check_out_cart_index_path
  end
end
