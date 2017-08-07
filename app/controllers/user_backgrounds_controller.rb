class UserBackgroundsController < ApplicationController
  def update
    if user_signed_in?
      current_user.background = params[:user_background]
      if current_user.save!
        render json: {
          status: 'ok',
          file: params[:user_background],
          url: { normal: current_user.background.url }
        }
      end
    end
  end
end
