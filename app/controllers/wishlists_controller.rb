class WishlistsController < ApplicationController
  before_action :find_work
  before_action :check_user_sign_in

  def add
    wishlist = current_user.wishlist || current_user.build_wishlist
    wishlist.works << @work
    wishlist.save!
    render json: { status: :success, message: current_user.role }, status: :ok
  end

  def destroy
    wishlist = current_user.wishlist || current_user.build_wishlist
    if wishlist.works.destroy(@work)
      render json: { status: :success }, status: :ok
    else
      render json: { status: :error, message: @work.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_work
    @work = Work.find params[:id]
  end

  def check_user_sign_in
    unless user_signed_in?
      user = User.new_guest
      sign_in user
    end
  end
end
